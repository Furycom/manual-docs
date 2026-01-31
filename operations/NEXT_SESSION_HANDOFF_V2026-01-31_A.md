# NEXT SESSION HANDOFF — 2026-01-31 (A)

Repo: /home/furycom/manual-docs
Branch: main

## Etat observé (validé)
- MCP Health: OK.
- OpenAPI: /bruce/* = 8 routes (voir /openapi.json).
- DB: `public.v_expected_docker_services_enforced` est VIDE pour `mcp-gateway` et `furyssh`.
- Issues: TrueNAS remonte DEGRADED/FAILING_DEV mais est **deferred** (ne pas traiter maintenant).

## Règle canon (API MCP)
- La vérité des endpoints MCP = `GET /openapi.json`.
- Ne pas utiliser `/bruce/introspect/observed/*` (absent du gateway actuel).

## Next session (1 bloc)
1) Bootstrap (preuve + smoke) :
   `/home/furycom/bootstrap.sh | sed -n '1,260p'`

2) Vérif DB (doit rester vide) :
   ssh -o BatchMode=yes -o ConnectTimeout=5 supabase \
     'docker exec -i supabase-db psql -U postgres -d postgres -X -q -P pager=off -c "select hostname, container_name, lifecycle_state, expected_state, severity from public.v_expected_docker_services_enforced where hostname in ('\''mcp-gateway'\'','\''furyssh'\'') order by hostname, container_name;"' \
     | sed -n '1,220p'

3) Issues open (doit rester TrueNAS seulement, mais on ignore) :
   (voir /home/furycom/bootstrap.sh)
