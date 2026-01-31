# ERRATUM — Canonique (V2)

## Règles
- Chaque correction/décision durable est ajoutée ici, datée, courte.
- Pas de roman, uniquement des faits et impacts.

## Entrées
- 2026-01-19: ajout de RAG_EMBED_RUNBOOK (procédure relance + vérif embeddings RAG, safe-Termix).
- 2026-01-19: ajout de INDEX_GLOBAL (point d’entrée unique vers canonique + knowledge + scope embeddable).
- 2026-01-19: ajout de INDEX_EMBEDDABLE (scope + exclusions + pointeurs LATEST) dans operations/.
- 2026-01-19: création du set canonique 8 fichiers *_LATEST.md et procédure de démarrage standard.
- 2026-01-19: initialisation git local pour manual-docs (branche main).
- 2026-01-19: ajout dossier knowledge/ et import des exports mcp-manual (LATEST + historiques).
- 2026-01-19: définition du scope embeddable (operations+knowledge) + exclusions par défaut (snapshots, backups, bruit, .ssh, env/keys).

- 2026-01-31: vérité MCP = OpenAPI. Les routes actives /bruce/* sont exactement celles listées par GET /openapi.json.
  - Impacts: ne pas utiliser /bruce/introspect/observed/* (non exposé par le gateway actuel).
  - Routes actuelles: /bruce/config/llm, /bruce/introspect/docker/summary, /bruce/introspect/last-seen, /bruce/issues/open, /bruce/memory/append, /bruce/rag/search, /bruce/rag/context, /bruce/rag/metrics.
