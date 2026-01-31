# NEXT SESSION HANDOFF — 2026-01-28 (MANUAL)

File: NEXT_SESSION_HANDOFF_V2026-01-28_220717Z_MANUAL.md

Date (UTC): 2026-01-28
Repo: /home/furycom/manual-docs
Branch: main

## Etat (résultat)
- Faux CRITICAL docker corrigés via `docker_service_intent`:
  - `mcp-gateway/*` -> `retired` (doublons; `furymcp/*` existe)
  - `furyssh/*` -> `retired` (hostname jamais observé)
- MCP `/bruce/issues/open`: plus aucun issue docker. Reste TrueNAS uniquement (deferred).

## Clarification (vues)
- `v_expected_docker_services_effective` peut inclure `retired`.
- Vue “enforced” ajoutée: `public.v_expected_docker_services_enforced` (active + enforce_after ok).

## Next session (1 bloc)
1) `/home/furycom/bootstrap.sh | sed -n '1,260p'`
2) Vérifs bornées:

- Enforced view doit être VIDE pour `mcp-gateway` et `furyssh` (SQL literals corrects):
  ssh -o BatchMode=yes -o ConnectTimeout=5 supabase \
    'docker exec -i supabase-db psql -U postgres -d postgres -X -q -P pager=off -c "select hostname, container_name, lifecycle_state, expected_state, severity from public.v_expected_docker_services_enforced where hostname in ('\''mcp-gateway'\'','\''furyssh'\'') order by hostname, container_name;"' \
    | sed -n '1,220p'

- MCP issues open (doit être TrueNAS seulement):
  TOKEN="$(docker exec mcp-gateway sh -lc '\''printf %s "$BRUCE_AUTH_TOKEN"'\'' | tr -d '\''\r\n'\'')"
  curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" http://192.168.2.230:4000/bruce/issues/open | sed -n '1,220p'
