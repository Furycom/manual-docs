#!/usr/bin/env bash
# bruce_close_session.sh
# Generate a versioned NEXT_SESSION_HANDOFF + repoint LATEST + git commit.
# Goals: fast, no recursion, timeouts per request, never print token.
# Note: intentionally NO 'set -euo pipefail'.

# --- guard against recursion / runaway shells ---
if [ "${BRUCE_CLOSE_SESSION_RUNNING:-0}" = "1" ]; then
  echo "[ERROR] bruce_close_session: recursion detected (BRUCE_CLOSE_SESSION_RUNNING=1). Aborting."
  exit 2
fi
export BRUCE_CLOSE_SESSION_RUNNING=1

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
MAX_TIME="6"  # per curl request

RUN_TMP="${REPO}/.run_tmp"
mkdir -p "$RUN_TMP" 2>/dev/null || true
chmod 700 "$RUN_TMP" 2>/dev/null || true

now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
day_utc="$(date -u +"%Y-%m-%d")"
stamp_utc="$(date -u +"%H%M%SZ")"

branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
head_before="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

pid="$$"
F_HEALTH="${RUN_TMP}/mcp_health_${pid}.json"
F_METRICS="${RUN_TMP}/mcp_metrics_${pid}.json"
F_LASTSEEN="${RUN_TMP}/mcp_last_seen_${pid}.json"
F_DOCKERSUM="${RUN_TMP}/mcp_docker_sum_${pid}.json"
F_ISSUES="${RUN_TMP}/mcp_issues_${pid}.json"

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
  curl_to_file "${BASE}/health" "$F_HEALTH" ""
  curl_to_file "${BASE}/bruce/rag/metrics" "$F_METRICS" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/introspect/last-seen" "$F_LASTSEEN" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/introspect/docker/summary" "$F_DOCKERSUM" "X-BRUCE-TOKEN: ${TOKEN}"
  curl_to_file "${BASE}/bruce/issues/open" "$F_ISSUES" "X-BRUCE-TOKEN: ${TOKEN}"

  health_dbg="$(curl_dbg "${BASE}/health" "")"
  metrics_dbg="$(curl_dbg "${BASE}/bruce/rag/metrics" "X-BRUCE-TOKEN: ${TOKEN}")"
  issues_dbg="$(curl_dbg "${BASE}/bruce/issues/open" "X-BRUCE-TOKEN: ${TOKEN}")"
  last_seen_dbg="$(curl_dbg "${BASE}/bruce/introspect/last-seen" "X-BRUCE-TOKEN: ${TOKEN}")"
  docker_sum_dbg="$(curl_dbg "${BASE}/bruce/introspect/docker/summary" "X-BRUCE-TOKEN: ${TOKEN}")"

  # --- BRUCE-only parse: only docker domain ---
  issues_counts_and_nextstep="$(
    python3 - <<'PY' 2>/dev/null
import json, pathlib
p = pathlib.Path("'"$F_ISSUES"'")
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
if not raw:
    print("counts: unavailable (empty response)")
    print("NEXTSTEP: BRUCE-only: inspect docker expected/observed (no issues payload)")
    raise SystemExit(0)
try:
    obj = json.loads(raw)
except Exception:
    print("counts: unavailable (invalid json)")
    print("NEXTSTEP: BRUCE-only: inspect docker expected/observed (invalid issues json)")
    raise SystemExit(0)

data = obj.get("data") if isinstance(obj, dict) else None
if not isinstance(data, list):
    print("counts: unavailable (no data array)")
    print("NEXTSTEP: BRUCE-only: inspect docker expected/observed (no data array)")
    raise SystemExit(0)

docker_items = [it for it in data if (it.get("domain") or "").lower() == "docker"]

crit = 0
warn = 0
crit_lines = []

for it in docker_items:
    sev = (it.get("severity") or "").lower()
    t = it.get("type")
    if sev == "critical":
        crit += 1
        if t == "SERVICE_MISSING":
            h = it.get("scope1")
            c = it.get("scope2")
            crit_lines.append(f"- CRITICAL SERVICE_MISSING: host={h} container={c}")
        else:
            msg = (it.get("message") or "")[:140]
            crit_lines.append(f"- CRITICAL {t}: {msg}")
    elif sev == "warning":
        warn += 1

print(f"counts: critical={crit} warning={warn}")
if crit_lines:
    print("critical_list_bruce_only:")
    for line in crit_lines[:10]:
        print(line)

if crit_lines:
    # first SERVICE_MISSING if present
    sm = next((l for l in crit_lines if "SERVICE_MISSING" in l), None)
    if sm:
        # extract host/container from line
        parts = sm.replace("- CRITICAL SERVICE_MISSING: ", "").strip()
        print(f"NEXTSTEP: BRUCE-only: fix SERVICE_MISSING ({parts})")
    else:
        print("NEXTSTEP: BRUCE-only: resolve critical docker issue(s)")
else:
    print("NEXTSTEP: BRUCE-only: MCP-first; no critical docker issue detected")
PY
  )"

  issues_preview="$(
    python3 - <<'PY' 2>/dev/null
import json, pathlib
p = pathlib.Path("'"$F_ISSUES"'")
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
if not raw:
    print("{}")
    raise SystemExit(0)
try:
    obj = json.loads(raw)
except Exception:
    print("{}")
    raise SystemExit(0)

data = obj.get("data") if isinstance(obj, dict) else None
if not isinstance(data, list):
    print("{}")
    raise SystemExit(0)

docker_items = [it for it in data if (it.get("domain") or "").lower() == "docker"]
out = {"ok": obj.get("ok", True), "status": obj.get("status", 200), "data": docker_items}
s = json.dumps(out, separators=(",",":"))
print(s[:600])
PY
  )"

  nextstep="$(printf '%s\n' "$issues_counts_and_nextstep" | grep -E '^NEXTSTEP:' | head -n 1 | sed 's/^NEXTSTEP:[ ]*//')"
  [ -n "$nextstep" ] || nextstep="BRUCE-only: inspect docker expected/observed (no NEXTSTEP parsed)"

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
    echo "- Se concentrer uniquement sur BRUCE (docker expected/observed + collectors + MCP health)."
    echo "- Ignorer les issues hors BRUCE pour cette session."
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
    echo "### Issues preview (BRUCE-only, 600 chars)"
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

run_all
