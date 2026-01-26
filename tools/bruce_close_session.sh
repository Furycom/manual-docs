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
MAX_TIME="6"        # per curl
OVERALL_TIMEOUT="60" # whole run

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

cleanup() {
  rm -f "$F_HEALTH" "$F_METRICS" "$F_LASTSEEN" "$F_DOCKERSUM" "$F_ISSUES" 2>/dev/null || true
  unset BRUCE_CLOSE_SESSION_RUNNING
}
trap cleanup EXIT

# token (never print)
TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null | tr -d '\r\n')"

curl_to_file() {
  # $1=url $2=outfile $3=header(optional)
  local url="$1"
  local out="$2"
  local hdr="${3:-}"

  : > "$out" 2>/dev/null || true

  if [ -n "$hdr" ]; then
    curl -sS --max-time "$MAX_TIME" -H "$hdr" -o "$out" "$url" 2>/dev/null || true
  else
    curl -sS --max-time "$MAX_TIME" -o "$out" "$url" 2>/dev/null || true
  fi

  # normalize CRLF -> LF (safe even if empty)
  tr -d '\r' < "$out" > "${out}.tmp" 2>/dev/null || true
  mv -f "${out}.tmp" "$out" 2>/dev/null || true
}

curl_dbg() {
  # $1=url $2=header(optional)
  local url="$1"
  local hdr="${2:-}"
  if [ -n "$hdr" ]; then
    curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "$hdr" "$url" 2>/dev/null || echo "http=000 bytes=0"
  else
    curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" "$url" 2>/dev/null || echo "http=000 bytes=0"
  fi
}

run_all() {
  # Collect MCP responses
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

  # Parse issues summary + decide next step
  issues_summary_and_next="$(
    python3 - <<PY 2>/dev/null
import json, pathlib

p = pathlib.Path("${F_ISSUES}")
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
crit = 0
warn = 0
crit_lines = []
has_pool_fail = False
has_service_missing = False

if raw:
    try:
        obj = json.loads(raw)
        data = obj.get("data") if isinstance(obj, dict) else None
        if isinstance(data, list):
            for it in data:
                sev = (it.get("severity") or "").lower()
                t = it.get("type")
                if sev == "critical":
                    crit += 1
                    if t == "pool_status":
                        has_pool_fail = True
                        payload = it.get("payload") or {}
                        pool = payload.get("pool_name")
                        code = payload.get("status_code")
                        crit_lines.append(f"- CRITICAL pool_status: pool={pool} code={code}")
                    elif t == "SERVICE_MISSING":
                        has_service_missing = True
                        h = it.get("scope1")
                        c = it.get("scope2")
                        crit_lines.append(f"- CRITICAL SERVICE_MISSING: host={h} container={c}")
                    else:
                        msg = (it.get("message") or "")[:140]
                        crit_lines.append(f"- CRITICAL {t}: {msg}")
                elif sev == "warning":
                    warn += 1
    except Exception:
        raw = ""

if not raw:
    print("counts: unavailable (empty/invalid response)")
    print("NEXTSTEP: rerun /home/furycom/bootstrap.sh then retry /bruce/issues/open")
else:
    print(f"counts: critical={crit} warning={warn}")
    if crit_lines:
        print("critical_list:")
        for line in crit_lines[:10]:
            print(line)
    if has_pool_fail:
        print("NEXTSTEP: priority TrueNAS pool DEGRADED (FAILING_DEV) -> diagnose disk / resilver / SMART on TrueNAS")
    elif has_service_missing:
        print("NEXTSTEP: docker expected/observed mismatch -> why container youthful_pike expected on furycomai but not observed")
    else:
        print("NEXTSTEP: no critical -> run /home/furycom/bootstrap.sh and pick one open item")
PY
  )"

  issues_counts="$(printf '%s\n' "$issues_summary_and_next" | sed -n '1,40p')"
  nextstep="$(printf '%s\n' "$issues_summary_and_next" | grep -E '^NEXTSTEP:' | sed -n '1p' | sed 's/^NEXTSTEP:[ ]*//')"

  # Health short (single line)
  health_short="$(tr -d '\n' < "$F_HEALTH" | cut -c1-260)"

  # Issues preview (bounded) - show first 600 chars
  issues_preview="$(tr -d '\n' < "$F_ISSUES" | cut -c1-600)"

  out_md="${OPS}/NEXT_SESSION_HANDOFF_V${day_utc}_${stamp_utc}.md"
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
    echo "- Demarrer MCP-first (etat observe -> choisir UNE action suivante)."
    echo "- Assurer que les canoniques LATEST sont coherents."
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
    echo "${health_short}"
    echo
    echo "### Issues ouvertes (resume)"
    printf '%s\n' "$issues_counts" | sed -n '1,60p'
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

  # repoint LATEST
  ln -sfn "$(basename "$out_md")" "$latest_link" 2>/dev/null || true

  # git commit
  git -C "$REPO" add "$out_md" "$latest_link" 2>/dev/null || true
  git -C "$REPO" commit -m "ops: close session ${day_utc} (AUTO)" >/dev/null 2>&1 || true

  head_after="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

  echo "[OK] session closed"
  echo "[OK] wrote: ${out_md}"
  echo "[OK] repointed: ${latest_link} -> $(readlink -f "$latest_link" 2>/dev/null || echo unknown)"
  echo "[OK] committed on ${branch} (${head_before} -> ${head_after})"
}

timeout "${OVERALL_TIMEOUT}" bash -c run_all 2>/dev/null || run_all
