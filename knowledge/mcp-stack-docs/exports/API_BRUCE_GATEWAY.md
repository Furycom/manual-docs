# API_BRUCE_GATEWAY — MCP Gateway (furymcp)

## Base URL (LAN)
http://192.168.2.230:4000

## Auth (token BRUCE)
Sur furymcp (hôte), dans /home/furycom/mcp-stack :

    BRUCE_TOKEN="$(docker compose exec -T mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"')"
    export BRUCE_TOKEN

Header à utiliser sur les endpoints protégés :

    Authorization: Bearer $BRUCE_TOKEN

## Endpoints (résumé)
Non-auth :
- GET /health
- GET /openapi.json
- GET /connectors
- GET /tools

Auth :
- GET /bruce/issues/open
- GET /bruce/introspect/last-seen?limit=N
- GET /bruce/introspect/docker/summary?limit=N
- POST /tools/supabase/exec-sql

## Tests copiables (preuves)

### Health (non-auth)
    curl -sS http://192.168.2.230:4000/health ; echo

### OpenAPI (non-auth)
    curl -sS http://192.168.2.230:4000/openapi.json | head -n 20 ; echo

### Issues open (auth)
    BRUCE_TOKEN="$(docker compose exec -T mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"')"
    curl -sS -H "Authorization: Bearer $BRUCE_TOKEN" \
      http://192.168.2.230:4000/bruce/issues/open ; echo

### Introspect last-seen (auth)
    BRUCE_TOKEN="$(docker compose exec -T mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"')"
    curl -sS -H "Authorization: Bearer $BRUCE_TOKEN" \
      "http://192.168.2.230:4000/bruce/introspect/last-seen?limit=5" ; echo

### Introspect docker summary (auth)
    BRUCE_TOKEN="$(docker compose exec -T mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"')"
    curl -sS -H "Authorization: Bearer $BRUCE_TOKEN" \
      "http://192.168.2.230:4000/bruce/introspect/docker/summary?limit=5" ; echo

### Exec SQL (auth) — petit test
    BRUCE_TOKEN="$(docker compose exec -T mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"')"
    curl -sS -X POST \
      -H "Authorization: Bearer $BRUCE_TOKEN" \
      -H "Content-Type: application/json" \
      http://192.168.2.230:4000/tools/supabase/exec-sql \
      -d '{"sql":"select 1 as ok"}' ; echo

## Erreurs attendues (sanity checks)
- Endpoints auth sans token : HTTP 401/403 (normal).
- Exec SQL : si payload trop gros ou SQL invalide : erreur (normal).

## Notes terrain
- Éditer les fichiers sur l’hôte (furymcp), pas “dans” le conteneur.
- /tools/supabase/exec-sql : à garder pour tests courts (éviter gros payloads).
