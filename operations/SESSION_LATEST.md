# SESSION LATEST — 2026-01-26

## Résumé
- README_SESSION_GUIDE mis à jour : création de `operations/README_SESSION_GUIDE_V3.md` et repoint `operations/README_SESSION_GUIDE_LATEST.md` -> V3.
- Validation du bootstrap MCP : `./bootstrap.sh` OK (health, openapi, endpoints protégés, smoke RAG).
- L’introspection MCP remonte des issues ouvertes à surveiller (TrueNAS pool dégradé, container attendu manquant sur furycomai).

## État MCP (constaté)
- Base MCP: http://192.168.2.230:4000
- Auth token chargé depuis container `mcp-gateway` (non affiché).
- Endpoints OK:
  - GET /health
  - GET /openapi.json
  - GET /bruce/introspect/docker/summary
  - GET /bruce/introspect/last-seen
  - GET /bruce/issues/open
  - GET /bruce/rag/metrics
  - POST /bruce/rag/search (payload JSON avec champ `q`)
  - POST /bruce/rag/context (payload JSON avec champ `q`)

## Notes
- README_SESSION_GUIDE_LATEST doit rester le point d’entrée “procédure de session”.
- RAG: utiliser `q` (string) ; `k` optionnel.
- Ne jamais afficher le token dans la sortie.
