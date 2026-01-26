#!/usr/bin/env bash

# bruce_close_session.sh
# Génère un NEXT_SESSION_HANDOFF versionné + repoint LATEST + commit.
# Objectifs: rapide, pas de récursion, timeouts, pas de token affiché.
# Note: pas de set -euo pipefail.

REPO="/home/furycom/manual-docs"
OPS="${REPO}/operations"

BASE="http://192.168.2.230:4000"
MAX_TIME="8"

TMP_DIR="/tmp"
F_HEALTH="${TMP_DIR}/mcp_health.json"
F_METRICS="${TMP_DIR}/mcp_metrics.json"
F_LASTSEEN="${TMP_DIR}/mcp_last_seen.json"
F_DOCKERSUM="${TMP_DIR}/mcp_docker_sum.json"
F_ISSUES="${TMP_DIR}/mcp_issues.json"

now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
day_utc="$(date -u +"%Y-%m-%d")"
stamp_utc="$(date -u +"%H%M%S")"

branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
head_before="$(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown")"

# --- token (safe, no print) ---
TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null | tr -d '\r\n')"

# --- helper: curl to file ---
curl_to_file() {
  # $1=url $2=outfile $3=header(optional)
  local url="$1"
  local out="$2"
  local hdr="$3"

  if [ -n "$hdr" ]; then
    curl -sS --max-time "$MAX_TIME" -H "$hdr" -o "$out" "$url" 2>/dev/null
  else
    curl -sS --max-time "$MAX_TIME" -o "$out" "$url" 2>/dev/null
  fi

  # normalize CRLF -> LF
  tr -d '\r' < "$out" > "${out}.tmp" 2>/dev/null
  mv -f "${out}.tmp" "$out" 2>/dev/null
}

# --- collect MCP responses (files) ---
: > "$F_HEALTH"
: > "$F_METRICS"
: > "$F_LASTSEEN"
: > "$F_DOCKERSUM"
: > "$F_ISSUES"

curl_to_file "${BASE}/health" "$F_HEALTH" ""
curl_to_file "${BASE}/bruce/rag/metrics" "$F_METRICS" "X-BRUCE-TOKEN: ${TOKEN}"
curl_to_file "${BASE}/bruce/introspect/last-seen" "$F_LASTSEEN" "X-BRUCE-TOKEN: ${TOKEN}"
curl_to_file "${BASE}/bruce/introspect/docker/summary" "$F_DOCKERSUM" "X-BRUCE-TOKEN: ${TOKEN}"
curl_to_file "${BASE}/bruce/issues/open" "$F_ISSUES" "X-BRUCE-TOKEN: ${TOKEN}"

# --- http/bytes debug (no body) ---
health_dbg="$(curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" "${BASE}/health" 2>/dev/null)"
metrics_dbg="$(curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "X-BRUCE-TOKEN: ${TOKEN}" "${BASE}/bruce/rag/metrics" 2>/dev/null)"
issues_dbg="$(curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "X-BRUCE-TOKEN: ${TOKEN}" "${BASE}/bruce/issues/open" 2>/dev/null)"
last_seen_dbg="$(curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "X-BRUCE-TOKEN: ${TOKEN}" "${BASE}/bruce/introspect/last-seen" 2>/dev/null)"
docker_sum_dbg="$(curl -sS --max-time "$MAX_TIME" -o /dev/null -w "http=%{http_code} bytes=%{size_download}" -H "X-BRUCE-TOKEN: ${TOKEN}" "${BASE}/bruce/introspect/docker/summary" 2>/dev/null)"

# --- parse issues summary from FILE (robuste) ---
issues_summary="$(
  python3 -c '
import json, sys, pathlib
p = pathlib.Path("/tmp/mcp_issues.json")
raw = p.read_text(errors="ignore").strip() if p.exists() else ""
if not raw:
    print("counts: unavailable (empty response)")
    sys.exit(0)
try:
    obj = json.loads(raw)
except Exception:
    print("counts: unavailable (invalid json)")
    sys.exit(0)

data = obj.get("data") if isinstance(obj, dict) else None
if not isinstance(data, list):
    print("counts: unavailable (no data array)")
    sys.exit(0)

crit = 0
warn = 0
crit_lines = []
for it in data:
    sev = (it.get("severity") or "").lower()
    t = it.get("type")
    if sev == "critical":
        crit += 1
        if t == "pool_status":
            payload = it.get("payload") or {}
            pool = payload.get("pool_name")
            code = payload.get("status_code")
            crit_lines.append(f"- CRITICAL pool_status: pool={pool} code={code}")
        elif t == "SERVICE_MISSING":
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
    print("critical_list:")
    for line in crit_lines[:10]:
        print(line)
' 2>/dev/null
)"

# --- heuristic next step ---
next_step="A) Priorité: TrueNAS pool DEGRADED (FAILING_DEV) -> diagnostiquer disque / état resilver / SMART (sur TrueNAS)."
if grep -q '"type":"pool_status"' "$F_ISSUES" 2>/dev/null; then
  next_step="A) Priorité: TrueNAS pool DEGRADED (FAILING_DEV) -> diagnostiquer disque / état resilver / SMART (sur TrueNAS)."
elif grep -q '"type":"SERVICE_MISSING"' "$F_ISSUES" 2>/dev/null; then
  next_step="A) Priorité: Docker attendu manquant (SERVICE_MISSING) -> corriger expected vs observed (pourquoi ce container est attendu sur furycomai)."
else
  next_step="A) MCP: valider /bruce/issues/open (auth) + décider une action unique basée sur la sortie."
fi

# --- write handoff ---
handoff="${OPS}/NEXT_SESSION_HANDOFF_V${day_utc}_${stamp_utc}Z.md"

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
  echo "- Assurer que les canoniques LATEST sont cohérents."
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
  if [ -s "$F_HEALTH" ]; then
    head -c 600 "$F_HEALTH"
    echo
  else
    echo "(empty)"
  fi
  echo
  echo "### Issues ouvertes (résumé)"
  echo "$issues_summary"
  echo
  echo "### Issues preview (borné, 40 lignes)"
  if [ -s "$F_ISSUES" ]; then
    sed -n '1,40p' "$F_ISSUES"
  else
    echo "(empty)"
  fi
  echo
  echo "## Meilleure prochaine étape (heuristique)"
  echo "$next_step"
  echo
  echo "## Séquence de démarrage (next session) — 1 bloc"
  echo "Sur \`furymcp\` :"
  echo "1) \`/home/furycom/bootstrap.sh | sed -n '1,220p'\`"
  echo "2) Reprendre ici avec la sortie, puis exécuter UNE action (selon \"Meilleure prochaine étape\")."
} > "$handoff"

# repoint LATEST
ln -sfn "$(basename "$handoff")" "${OPS}/NEXT_SESSION_HANDOFF_LATEST.md"

# commit
git -C "$REPO" add "$handoff" "${OPS}/NEXT_SESSION_HANDOFF_LATEST.md" >/dev/null 2>&1
git -C "$REPO" commit -m "ops: close session ${day_utc} (AUTO)" >/dev/null 2>&1

echo "[OK] session closed"
echo "[OK] wrote: ${handoff}"
echo "[OK] repointed: ${OPS}/NEXT_SESSION_HANDOFF_LATEST.md -> $(basename "$handoff")"
echo "[OK] committed on ${branch} ($(git -C "$REPO" rev-parse --short HEAD 2>/dev/null || echo "unknown"))"
