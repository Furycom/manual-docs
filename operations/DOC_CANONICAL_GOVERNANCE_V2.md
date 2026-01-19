# DOC CANONICAL GOVERNANCE — V2
Date (UTC): 2026-01-19T19:45:00Z
But: Tout ce qui guide BRUCE (plans, checklists, handoffs, décisions) vit DANS le Home Lab, est versionné, et reste retrouvable + embeddable.

## Emplacements (source of truth)
- Canonique (démarrage / décisions / état): /home/furycom/manual-docs/operations
- Knowledge (sources à embedder, non-canoniques): /home/furycom/manual-docs/knowledge
- Repo git local: /home/furycom/manual-docs (branche main)

## Set canonique (8 fichiers) — obligatoire
Voir la définition officielle: CANONICAL_SET_LATEST.md
Règle: les liens *_LATEST.md pointent vers la dernière version figée *_V*.md (sauf SESSION_LATEST.md qui est un fichier direct).

## Knowledge (embeddable) — conventions
Objectif: rendre la documentation consultable par MCP/LLM via embeddings/RAG, sans mélanger avec le canonique.

- knowledge/README.md décrit la structure.
- Chaque source externe importée doit aller dans knowledge/<source>/...
- Pour chaque source, créer un pointeur:
  - knowledge/<source>/LATEST.md (et/ou LATEST.txt) si pertinent.
- Conserver les exports historiques (versionnés) dans knowledge/<source>/exports/.

## Exclusions (non-canoniques)
- *.bak_* : artefacts de sauvegarde / copies temporaires
- _snapshots/*.tgz : preuves/gel d’état (conservées, mais non “canonique de lecture”)

## Procédure “import & compare” (externe -> homelab)
1) Placer/importer le contenu dans knowledge/<source>/... (pas dans operations/).
2) Ajouter/mettre à jour knowledge/<source>/LATEST.* si un “latest” existe.
3) Commit git local (message court, traçable).
4) Si des décisions/procédures doivent devenir canonique: les réécrire dans operations (nouvelle version *_V*.md) et repointer *_LATEST.md.

## Fin de session (obligatoire)
- Mettre à jour: SESSION_LATEST.md (si changements), NEXT_SESSION_HANDOFF (nouvelle version), et repointer les *_LATEST.md concernés.
- Commit git local (pas de push externe sans demande explicite).
