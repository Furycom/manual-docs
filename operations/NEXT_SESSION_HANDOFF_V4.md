# NEXT SESSION HANDOFF — V4
Date (UTC): 2026-01-20T02:45:00Z
Machine: furymcp
Contrainte: safe-Termix (outputs courts, pas de commandes “lourdes”)

## État (confirmé)
- Repo docs versionné localement: /home/furycom/manual-docs (main)
- Canonique (8 fichiers) en place: /home/furycom/manual-docs/operations
- Knowledge versionnée + pointeurs LATEST: /home/furycom/manual-docs/knowledge
- Index embeddable: /home/furycom/manual-docs/operations/INDEX_EMBEDDABLE_LATEST.md
- MCP Gateway: http://192.168.2.230:4000
  - OpenAPI: /openapi.json (public)
  - Endpoints utiles (auth requise pour certains):
    - /bruce/introspect/docker/summary (AUTH)
    - /bruce/introspect/last-seen (AUTH)
    - /bruce/issues/open (AUTH)
    - /bruce/memory/append (AUTH)
    - /bruce/rag/search (AUTH)
    - /health (public)

## Objectif prioritaire (prochaine session) — DOC ONLY
1) Mettre à jour/compléter l’INDEX (si jugé utile) en listant: canoniques + knowledge + pointeurs LATEST.
2) Standardiser une section “MCP Gateway / OpenAPI / Auth” (une seule vérité) dans la doc canonique.
3) Aligner SESSION_LATEST.md (garder l’historique, mais mettre l’état et l’objectif au début).

## Séquence courte (vérifications)

A) Canonique
- cd /home/furycom/manual-docs/operations
- ls -la *_LATEST.md SESSION_LATEST.md | head -n 80
- sed -n '1,120p' README_SESSION_GUIDE_LATEST.md
- sed -n '1,140p' CANONICAL_SET_LATEST.md
- sed -n '1,200p' INDEX_EMBEDDABLE_LATEST.md
- sed -n '1,200p' CHECKLIST_LATEST.md

B) Knowledge
- cd /home/furycom/manual-docs
- sed -n '1,200p' knowledge/README.md
- ls -la knowledge | head -n 80
- ls -la knowledge/mcp-manual | head -n 60

C) MCP Gateway (OpenAPI + introspection) — SAFE
- cd /home/furycom/manual-docs
- curl -fsS http://192.168.2.230:4000/health | head -n 40
- curl -fsS http://192.168.2.230:4000/openapi.json | head -n 40

# Auth token (NE PAS AFFICHER)
- BRUCE_TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null || true)"; test -n "$BRUCE_TOKEN"

# Introspection docker summary (AUTH)
- curl -fsS -H "Authorization: Bearer $BRUCE_TOKEN" http://192.168.2.230:4000/bruce/introspect/docker/summary | head -n 60

D) Git (local only)
- cd /home/furycom/manual-docs
- git status --porcelain=v1 | head -n 120
- git log -12 --oneline --decorate
