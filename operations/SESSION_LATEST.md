# SESSION LATEST — 2026-01-31

## Résumé
- Vérifs MCP: Health OK; vérité des endpoints = `GET /openapi.json` (8 routes /bruce/*).
- Canon mis à jour:
  - ERRATUM_V2: clarification OpenAPI + obsolescence de `/bruce/introspect/observed/*`.
  - NEXT_SESSION_HANDOFF_V2026-01-31_A + repoint NEXT_SESSION_HANDOFF_LATEST.
  - CHECKLIST_V3: ajout règle “TrueNAS critique mais deferred” (ne pas traiter sans demande explicite).
- Repo `manual-docs` rendu clean (plus de fichiers non trackés).

## État MCP (observé)
- Base: http://192.168.2.230:4000
- Health (observé): OK.
- OpenAPI /bruce/* (8):
  - /bruce/config/llm
  - /bruce/introspect/docker/summary
  - /bruce/introspect/last-seen
  - /bruce/issues/open
  - /bruce/memory/append
  - /bruce/rag/search
  - /bruce/rag/context
  - /bruce/rag/metrics

## Notes / Règles
- TrueNAS: pool `RZ1-5TB-4X` DEGRADED/FAILING_DEV reste critique; **deferred par défaut**.
