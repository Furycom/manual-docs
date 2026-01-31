#!/usr/bin/env bash
set -eu

BASE="http://192.168.2.230:4000"
GW_CONTAINER="mcp-gateway"
TMP="/tmp/mcp_openapi.json"

echo "=== BRUCE smoke (bounded) ==="
echo "whoami=$(whoami)"
echo "pwd=$(pwd)"
date -u +"date_utc=%Y-%m-%dT%H:%M:%SZ"
echo

echo "=== MCP health (no auth) ==="
curl -sS --max-time 5 "${BASE}/health" | sed -n '1,120p'
echo
echo

echo "=== MCP openapi (no auth, save) ==="
curl -sS --max-time 10 "${BASE}/openapi.json" -o "${TMP}"
ls -la "${TMP}" | sed -n '1,5p'
wc -c "${TMP}" 2>/dev/null || true
echo

echo "=== OpenAPI routes (/bruce/*) ==="
python3 - <<'PY'
import json
p="/tmp/mcp_openapi.json"
with open(p,"r",encoding="utf-8") as f:
    data=json.load(f)
paths=sorted([k for k in data.get("paths",{}).keys() if k.startswith("/bruce/")])
print("count(/bruce/*) =", len(paths))
print("\n".join(paths))
PY
echo

echo "=== load token (NO PRINT) ==="
if ! docker ps --format '{{.Names}}' | grep -qx "${GW_CONTAINER}"; then
  echo "[ERROR] container introuvable: ${GW_CONTAINER}"
  exit 1
fi

TOKEN="$(docker exec "${GW_CONTAINER}" sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' | tr -d '\r\n')"
if [ -z "${TOKEN}" ]; then
  echo "[ERROR] BRUCE_AUTH_TOKEN vide (env non présent)."
  exit 1
fi
echo "[OK] token loaded len=$(printf %s "${TOKEN}" | wc -c | tr -d ' ')"
echo

echo "=== smoke GET routes (auth) ==="
for u in \
  /bruce/config/llm \
  /bruce/introspect/docker/summary \
  /bruce/introspect/last-seen \
  /bruce/issues/open \
  /bruce/rag/metrics
do
  echo "--- GET $u ---"
  curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" "${BASE}${u}" | sed -n '1,220p'
  echo
done

echo "=== smoke POST routes (auth) ==="
echo "--- POST /bruce/rag/search ---"
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${BASE}/bruce/rag/search" \
  --data '{"q":"SESSION_LATEST","k":2}' \
  | sed -n '1,220p'
echo

echo "--- POST /bruce/rag/context ---"
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${BASE}/bruce/rag/context" \
  --data '{"q":"INDEX_GLOBAL_LATEST","k":1}' \
  | sed -n '1,180p'
echo

echo "=== memory append (session marker) ==="
NOW="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "${BASE}/bruce/memory/append" \
  --data "{\"source\":\"ops\",\"channel\":\"ops\",\"content\":\"${NOW} smoke: bruce_smoke.sh ok (copyback) — issues checked (truenas deferred)\",\"tags\":[\"session\",\"smoke\",\"copyback\"],\"metadata\":{\"script\":\"tools/bruce_smoke.sh\"}}" \
  | sed -n '1,160p'
echo
