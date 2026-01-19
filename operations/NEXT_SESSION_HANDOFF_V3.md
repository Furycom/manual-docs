# NEXT SESSION HANDOFF — V3
Date (UTC): 2026-01-19T21:10:51Z
Machine: furymcp
Contrainte: safe-Termix (outputs courts, pas de commandes “lourdes”)

## État (confirmé)
- Repo docs versionné localement: /home/furycom/manual-docs (main)
- Canonique (8 fichiers) en place: /home/furycom/manual-docs/operations
- Knowledge versionnée + pointeurs LATEST: /home/furycom/manual-docs/knowledge
- Index embeddable: /home/furycom/manual-docs/operations/INDEX_EMBEDDABLE_LATEST.md

## Objectif prioritaire (prochaine session) — DOC ONLY
1) Créer un INDEX global court (si jugé utile) listant: canoniques + sources knowledge + liens LATEST.
2) Standardiser “import & compare” sur 1 nouvelle source (DOC ONLY) sans ajouter de features.
3) Aligner/compacter SESSION_LATEST.md (garder historique, mais état au début).

## Séquence courte (vérifications)
A) Canonique
- cd /home/furycom/manual-docs/operations
- ls -la *_LATEST.md SESSION_LATEST.md | head -n 80
- sed -n '1,80p' README_SESSION_GUIDE_LATEST.md
- sed -n '1,120p' CANONICAL_SET_LATEST.md
- sed -n '1,160p' INDEX_EMBEDDABLE_LATEST.md

B) Knowledge
- cd /home/furycom/manual-docs
- sed -n '1,160p' knowledge/README.md
- ls -la knowledge | head -n 80
- ls -la knowledge/mcp-manual | head -n 60

C) Git (local only)
- cd /home/furycom/manual-docs
- git status --porcelain=v1 | head -n 80
- git log -8 --oneline --decorate
