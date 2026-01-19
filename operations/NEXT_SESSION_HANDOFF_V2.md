# NEXT SESSION HANDOFF — V2
Date (UTC): 2026-01-19T19:45:00Z
Machine: furymcp
Contrainte: safe-Termix (outputs courts, pas de commandes “lourdes”)

## État
- Repo docs versionné localement: /home/furycom/manual-docs (main)
- Canonique (8 fichiers) en place: /home/furycom/manual-docs/operations (voir CANONICAL_SET_LATEST.md)
- Knowledge importée (mcp-manual exports): /home/furycom/manual-docs/knowledge/mcp-manual/exports (LATEST.md/LATEST.txt)

## Objectif prioritaire (prochaine session)
1) Documentation d’indexation/embedding: définir noir sur blanc “quoi est embeddé” et “comment on relance” (DOC ONLY).
2) Procédure d’import standardisée: valider 1-2 nouvelles sources (DOC ONLY), sans ajouter de features.
3) Nettoyage doc: aligner SESSION_LATEST.md avec l’état réel Pack D (résumé court).

## Actions (séquence courte)
A) Vérifier canonique (liens LATEST)
- cd /home/furycom/manual-docs/operations
- ls -la *_LATEST.md SESSION_LATEST.md | head -n 80
- sed -n '1,80p' README_SESSION_GUIDE_LATEST.md
- sed -n '1,120p' CANONICAL_SET_LATEST.md

B) Vérifier knowledge importée
- cd /home/furycom/manual-docs
- sed -n '1,120p' knowledge/README.md
- ls -la knowledge/mcp-manual | head -n 60
- ls -la knowledge/mcp-manual/exports | head -n 20

C) Vérifier git (local only)
- cd /home/furycom/manual-docs
- git status --porcelain=v1 | head -n 80
- git log -5 --oneline --decorate

## Décisions à prendre (DOC ONLY)
D1) Scope embeddable: inclure operations + knowledge (md/txt) ? exclure _snapshots tgz ?
D2) Politique “LATEST”: pour knowledge, garder LATEST.* par source + exports datés.
D3) Format d’index: créer un petit INDEX (DOC) listant sources knowledge + canoniques.

