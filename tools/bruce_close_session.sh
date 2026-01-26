#!/usr/bin/env bash
# bruce_close_session.sh
# Generate a versioned NEXT_SESSION_HANDOFF + repoint LATEST + git commit.
# Goals: fast, no recursion, timeouts per request, never print token.
# Note: intentionally NO 'set -euo pipefail'.

# --- hard guard against recursion / runaway shells ---
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

now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
day_utc="$(date -u +"%Y-%m-%d")"
stamp_utc="$(date -u +"%H%M%SZ")"

branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
head_before="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

pid="$$"
F_HEALTH="/tmp/mcp_health_${pid}.json"
F_METRICS="/tmp/mcp_metrics_${pid}.json"
F_LASTSEEN="/tmp/mcp_last_seen_${pid}.json"
F_DOCKERSUM="/tmp/mcp_docker_sum_${pid}.json"
F_ISSUES="/tmp/mcp_issues_${pid}.json"

TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null | tr -d '\r\n')"

curl_to_file() {
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

  issues_counts_and_nextstep="$(
    python3 - <<'PY' 2>/dev/null
import json, pathlib, sys

p = pathlib.Path(sys.argv[1])
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
if not raw:
    print("counts: unavailable (empty response)")
    print("NEXTSTEP: BRUCE-only: inspect docker issues (no data)")
    raise SystemExit(0)

try:
    obj = json.loads(raw)
except Exception:
    print("counts: unavailable (invalid json)")
    print("NEXTSTEP: BRUCE-only: inspect docker issues (invalid json)")
    raise SystemExit(0)

data = obj.get("data") if isinstance(obj, dict) else None
if not isinstance(data, list):
    print("counts: unavailable (no data array)")
    print("NEXTSTEP: BRUCE-only: inspect docker issues (no data array)")
    raise SystemExit(0)

crit = 0
warn = 0
docker_crit_lines = []

for it in data:
    sev = (it.get("severity") or "").lower()
    if sev == "critical":
        crit += 1
    elif sev == "warning":
        warn += 1

    # BRUCE-only focus: domain=docker only
    if (it.get("domain") or "").lower() != "docker":
        continue
    if (it.get("severity") or "").lower() != "critical":
        continue

    t = it.get("type")
    if t == "SERVICE_MISSING":
        h = it.get("scope1")
        c = it.get("scope2")
        docker_crit_lines.append(f"- CRITICAL SERVICE_MISSING: host={h} container={c}")
    else:
        msg = (it.get("message") or "")[:140]
        docker_crit_lines.append(f"- CRITICAL {t}: {msg}")

print(f"counts: critical={crit} warning={warn}")
if docker_crit_lines:
    print("critical_list_bruce_only:")
    for line in docker_crit_lines[:10]:
        print(line)
    # nextstep: first docker critical line
    first = docker_crit_lines[0]
    # extract host/container if present
    host = None
    cont = None
    if "host=" in first:
        host = first.split("host=",1)[1].split()[0].strip()
    if "container=" in first:
        cont = first.split("container=",1)[1].split()[0].strip()
    if host and cont:
        print(f"NEXTSTEP: BRUCE-only: fix SERVICE_MISSING on {host} (expected container {cont})")
    else:
        print("NEXTSTEP: BRUCE-only: fix docker critical issue (see list above)")
else:
    print("NEXTSTEP: BRUCE-only: no critical docker issues found (defer non-BRUCE domains)")
PY
  "$F_ISSUES"
  )"

  nextstep="$(printf '%s\n' "$issues_counts_and_nextstep" | awk -F'NEXTSTEP: ' '/^NEXTSTEP: /{print $2; exit}')"
  [ -n "$nextstep" ] || nextstep="BRUCE-only: inspect docker expected/observed (no NEXTSTEP parsed)"

  issues_preview="$(tr -d '\r' < "$F_ISSUES" | head -c 600)"

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
    echo "- Ne pas traiter TrueNAS dans cette session (deferred)."
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
    printf '%s\n' "$issues_counts_and_nextstep" | sed -n '1,120p'
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

  git -C "$REPO" add "$out_md" "$latest_link" tools/bruce_close_session.sh 2>/dev/null || true
  git -C "$REPO" commit -m "tools: fix close-session timeout + BRUCE-only nextstep" >/dev/null 2>&1 || true

  head_after="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

  echo "[OK] session closed"
  echo "[OK] wrote: ${out_md}"
  echo "[OK] repointed: ${latest_link} -> $(readlink -f "$latest_link" 2>/dev/null || echo unknown)"
  echo "[OK] committed on ${branch} (${head_before} -> ${head_after})"
}

run_all
