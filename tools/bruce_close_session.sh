#!/usr/bin/env bash
# bruce_close_session.sh
# Generate a versioned NEXT_SESSION_HANDOFF + repoint LATEST + git commit.
# Goals: fast, no recursion, timeouts, never print token.
# Note: intentionally NO 'set -euo pipefail'.

# --- hard guard against recursion / runaway shells ---
if [ "${BRUCE_CLOSE_SESSION_RUNNING:-0}" = "1" ]; then
  echo "[ERROR] bruce_close_session: recursion detected (BRUCE_CLOSE_SESSION_RUNNING=1). Aborting."
  exit 2
fi
export BRUCE_CLOSE_SESSION_RUNNING=1

# If shell nesting is already crazy, abort early.
shlvl="${SHLVL:-0}"
case "$shlvl" in
  ''|*[!0-9]*) shlvl=0 ;;
esac
if [ "$shlvl" -ge 50 ]; then
  echo "[ERROR] bruce_close_session: SHLVL too high (${shlvl}). Aborting."
  exit 3
fi

REPO="/home/furycom/manual-docs"
OPS="${REPO}/operations"

BASE="http://192.168.2.230:4000"
MAX_TIME="6"          # per curl
OVERALL_TIMEOUT="60"  # whole run

now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
day_utc="$(date -u +"%Y-%m-%d")"
stamp_utc="$(date -u +"%H%M%SZ")"

branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
head_before="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

# temp files unique per run
pid="$$"
F_HEALTH="/tmp/mcp_health_${pid}.json"
F_METRICS="/tmp/mcp_metrics_${pid}.json"
F_LASTSEEN="/tmp/mcp_last_seen_${pid}.json"
F_DOCKERSUM="/tmp/mcp_docker_sum_${pid}.json"
F_ISSUES="/tmp/mcp_issues_${pid}.json"

# --- token (safe, no print) ---
TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null | tr -d '\r\n')"

curl_to_file() {
  # $1=url $2=outfile $3=header(optional)
  local url="$1"
  local out="$2"
  local hdr="$3"

  : > "$out" 2>/dev/null
  if [ -n "$hdr" ]; then
    curl -sS --max-time "$MAX_TIME" -H "$hdr" -o "$out" "$url" 2>/dev/null
  else
    curl -sS --max-time "$MAX_TIME" -o "$out" "$url" 2>/dev/null
  fi

  # normalize CRLF -> LF
  tr -d '\r' < "$out" > "${out}.tmp" 2>/dev/null
  mv -f "${out}.tmp" "$out" 2>/dev/null
}

curl_dbg() {
  # $1=url $2=header(optional)
  local url="$1"
  local hdr="$2"
  if [ -n "$hdr" ]; then
    curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "$hdr" "$url" 2>/dev/null
  else
    curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" "$url" 2>/dev/null
  fi
}

run_all() {
  # --- collect MCP responses (files) ---
  curl_to_file "${BASE}/health" "$F_HEALTH" ""
  curl_to_file "${BASE}/bruce/rag/metrics" "$F_METRICS" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/introspect/last-seen" "$F_LASTSEEN" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/introspect/docker/summary" "$F_DOCKERSUM" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/issues/open" "$F_ISSUES" "X-BRUCE-TOKEN: ${TOKEN}"

  # --- http/bytes debug (no body) ---
  health_dbg="$(curl_dbg "${BASE}/health" "")"
  metrics_dbg="$(curl_dbg "${BASE}/bruce/rag/metrics" "X-BRUCE-TOKEN: ${TOKEN}")"
  issues_dbg="$(curl_dbg "${BASE}/bruce/issues/open" "X-BRUCE-TOKEN: ${TOKEN}")"
  last_seen_dbg="$(curl_dbg "${BASE}/bruce/introspect/last-seen" "X-BRUCE-TOKEN: ${TOKEN}")"
  docker_sum_dbg="$(curl_dbg "${BASE}/bruce/introspect/docker/summary" "X-BRUCE-TOKEN: ${TOKEN}")"

  # --- parse issues summary from FILE (BRUCE-only nextstep; ignore domain=truenas) ---
  issues_counts_and_nextstep="$(
    F_ISSUES_PATH="$F_ISSUES" python3 - <<'PY' 2>/dev/null
import json, os, pathlib

p = pathlib.Path(os.environ.get("F_ISSUES_PATH","/tmp/mcp_issues.json"))
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
if not raw:
    print("counts: unavailable (empty response)")
    print("NEXTSTEP: BRUCE-only -> run bootstrap, then re-check /bruce/issues/open")
    raise SystemExit(0)

try:
    obj = json.loads(raw)
except Exception:
    print("counts: unavailable (invalid json)")
    print("NEXTSTEP: BRUCE-only -> run bootstrap, then re-check /bruce/issues/open")
    raise SystemExit(0)

data = obj.get("data") if isinstance(obj, dict) else None
if not isinstance(data, list):
    print("counts: unavailable (no data array)")
    print("NEXTSTEP: BRUCE-only -> run bootstrap, then re-check /bruce/issues/open")
    raise SystemExit(0)

crit = 0
warn = 0
crit_lines = []
deferred_lines = []

# choose BRUCE-only next step: first CRITICAL where domain != truenas; prefer SERVICE_MISSING/docker
best = None
best_rank = 10**9

def rank(item):
    # lower is better
    t = (item.get("type") or "").upper()
    d = (item.get("domain") or "").lower()
    sev = (item.get("severity") or "").lower()
    if sev != "critical":
        return 10**8
    if d == "truenas":
        return 10**7
    if t == "SERVICE_MISSING" and d == "docker":
        return 0
    return 1000

for it in data:
    sev = (it.get("severity") or "").lower()
    dom = (it.get("domain") or "").lower()
    t = it.get("type")

    if sev == "critical":
        crit += 1
        if dom == "truenas":
            # keep as deferred visibility
            if t == "pool_status":
                payload = it.get("payload") or {}
                pool = payload.get("pool_name")
                code = payload.get("status_code")
                deferred_lines.append(f"- DEFERRED truenas pool_status: pool={pool} code={code}")
            else:
                msg = (it.get("message") or "")[:140]
                deferred_lines.append(f"- DEFERRED truenas {t}: {msg}")
        else:
            if t == "pool_status":
                payload = it.get("payload") or {}
                pool = payload.get("pool_name")
                code = payload.get("status_code")
                crit_lines.append(f"- CRITICAL pool_status: pool={pool} code={code}")
            elif (t or "").upper() == "SERVICE_MISSING":
                h = it.get("scope1")
                c = it.get("scope2")
                crit_lines.append(f"- CRITICAL SERVICE_MISSING: host={h} container={c}")
            else:
                msg = (it.get("message") or "")[:140]
                crit_lines.append(f"- CRITICAL {t}: {msg}")

    elif sev == "warning":
        warn += 1

    r = rank(it)
    if r < best_rank:
        best_rank = r
        best = it

print(f"counts: critical={crit} warning={warn}")
if crit_lines:
    print("critical_list:")
    for line in crit_lines[:10]:
        print(line)

if deferred_lines:
    print("deferred_list:")
    for line in deferred_lines[:10]:
        print(line)

# BRUCE-only nextstep
if best and (best.get("domain") or "").lower() != "truenas":
    t = (best.get("type") or "").upper()
    dom = (best.get("domain") or "").lower()
    if t == "SERVICE_MISSING" and dom == "docker":
        h = best.get("scope1")
        c = best.get("scope2")
        print(f"NEXTSTEP: BRUCE-only -> fix SERVICE_MISSING (host={h}, container={c})")
    else:
        msg = (best.get("message") or "")[:140]
        print(f"NEXTSTEP: BRUCE-only -> address CRITICAL {t} ({dom}): {msg}")
else:
    print("NEXTSTEP: BRUCE-only -> fix docker expected/observed drift (no non-truenas critical found)")
PY
  )"

  issues_preview="$(
    F_ISSUES_PATH="$F_ISSUES" python3 - <<'PY' 2>/dev/null
import os, pathlib, re
p = pathlib.Path(os.environ.get("F_ISSUES_PATH","/tmp/mcp_issues.json"))
s = p.read_text(errors="ignore") if p.exists() else ""
s = re.sub(r'\s+', ' ', s).strip()
print((s[:600] + ("..." if len(s) > 600 else "")) if s else "(empty)")
PY
  )"

  # extract NEXTSTEP line (single)
  nextstep="$(printf '%s\n' "$issues_counts_and_nextstep" | awk -F'NEXTSTEP: ' 'NF>1{print $2; exit}')"
  if [ -z "$nextstep" ]; then
    nextstep="BRUCE-only -> run bootstrap then pick ONE action from issues"
  fi

  out_md="${OPS}/NEXT_SESSION_HANDOFF_V${day_utc}_${stamp_utc}_AUTO.md"
  latest_link="${OPS}/NEXT_SESSION_HANDOFF_LATEST.md"

  {
    echo "# NEXT SESSION HANDOFF — ${day_utc} (AUTO)"
    echo
    echo "Date (UTC): ${now_utc}"
    echo "Repo: ${REPO}"
    echo "Branch: ${branch}"
    echo "HEAD (before write): ${head_before}"
    echo
    echo "## Objectif (prochaine session)"
    echo "- Démarrer MCP-first (état observé -> choisir UNE action suivante)."
    echo "- Améliorer BRUCE (objectif final -> déjà fait -> reste à faire -> impact/urgence)."
    echo "- Scope: BRUCE uniquement (ignorer truenas dans le NEXTSTEP)."
    echo
    echo "## MCP (collecte)"
    echo "Base: ${BASE}"
    echo
    echo "### MCP http/bytes (debug)"
    echo "- health:     ${health_dbg}"
    echo "- metrics:    ${metrics_dbg}"
    echo "- issues:     ${issues_dbg}"
    echo "- last-seen:  ${last_seen_dbg}"
    echo "- docker-sum: ${docker_sum_dbg}"
    echo
    echo "Health (raw, court):"
    tr -d '\r' < "$F_HEALTH" | head -c 450
    echo
    echo
    echo "### Issues ouvertes (resume)"
    printf '%s\n' "$issues_counts_and_nextstep" | sed -n '1,80p'
    echo
    echo "### Issues preview (borne, 600 chars)"
    echo "${issues_preview}"
    echo
    echo "## Meilleure prochaine etape (heuristique)"
    echo "${nextstep}"
    echo
    echo "## Sequence de demarrage (next session) — 1 bloc"
    echo "Sur \`furymcp\` :"
    echo "1) \`/home/furycom/bootstrap.sh | sed -n '1,220p'\`"
    echo "2) Reprendre ici avec la sortie, puis executer UNE action (selon \"Meilleure prochaine etape\")."
  } > "$out_md"

  ln -sfn "$(basename "$out_md")" "$latest_link" 2>/dev/null || true

  git -C "$REPO" add "$out_md" "$latest_link" 2>/dev/null || true
  git -C "$REPO" commit -m "ops: close session ${day_utc} (AUTO)" >/dev/null 2>&1 || true

  head_after="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

  echo "[OK] session closed"
  echo "[OK] wrote: ${out_md}"
  echo "[OK] repointed: ${latest_link} -> $(readlink -f "$latest_link" 2>/dev/null || echo unknown)"
  echo "[OK] committed on ${branch} (${head_before} -> ${head_after})"
}

# overall timeout (best-effort)
if command -v timeout >/dev/null 2>&1; then
  timeout "${OVERALL_TIMEOUT}" bash -c "$(declare -f run_all); run_all" 2>/dev/null || run_all
else
  run_all
fi
