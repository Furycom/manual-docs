# DOC CANONICAL GOVERNANCE — V3
Date (UTC): 2026-01-20
But: Tout ce qui guide BRUCE vit DANS le Home Lab, est versionné, et reste retrouvable + embeddable (RAG).

## Emplacements (source of truth)
- Canonique (démarrage / décisions / état): /home/furycom/manual-docs/operations
- Knowledge (sources à embedder, non-canoniques): /home/furycom/manual-docs/knowledge
- Repo git local: /home/furycom/manual-docs (branche main)

## Set canonique (8 fichiers) — obligatoire
Voir la définition officielle: CANONICAL_SET_LATEST.md
Règle: les liens *_LATEST.md pointent vers la dernière version figée *_V*.md (sauf SESSION_LATEST.md qui est un fichier direct).

## Knowledge (embeddable) — conventions
Objectif: rendre la documentation consultable via MCP/LLM (embeddings/RAG), sans mélanger avec le canonique.

- knowledge/README.md décrit la structure.
- Chaque source externe importée va dans knowledge/<source>/...
- Pour chaque source, créer un pointeur:
  - knowledge/<source>/LATEST.md (et/ou LATEST.txt si pertinent).
- Conserver les historiques dans knowledge/<source>/exports/.

Sources ajoutées (exemples):
- knowledge/mcp-manual/exports/ (exports md/txt) + knowledge/mcp-manual/extra/
- knowledge/mcp-stack-docs/exports/ (docs du stack, ex: API_BRUCE_GATEWAY.md)
- knowledge/mcp-manual-archive/exports/ (json/raw.json)
- knowledge/sessions/exports/ (notes de session isolées)

## Scope embeddable (règle simple)
Par défaut, le RAG peut indexer:
- operations/*.md (sauf preuves/snapshots)
- knowledge/**/*.md
- knowledge/**/*.txt
- knowledge/**/*.json

Exclusions par défaut (non embeddable):
- operations/_snapshots/*.tgz
- tout bruit d’exécution: __pycache__, *.pyc, *.log, *.tmp
- artefacts de sauvegarde: *.bak_*
- fichiers “clés/config” typiques: *.env, *.key, *.pem, *.token, et tout sous .ssh/

## Procédure “import & compare” (externe -> homelab)
1) Importer le contenu dans knowledge/<source>/... (pas dans operations/).
2) Mettre à jour knowledge/<source>/LATEST.* si un “latest” existe.
3) Commit git local (message court, traçable).
4) Si des décisions/procédures doivent devenir canonique: les réécrire dans operations (nouvelle version *_V*.md) et repointer *_LATEST.md.

## Fin de session (obligatoire)
- Mettre à jour: SESSION_LATEST.md (si changements), NEXT_SESSION_HANDOFF (nouvelle version), et repointer les *_LATEST.md concernés.
- Commit git local (pas de push externe sans demande explicite).

## Visions (Plan Total) — règles anti-contradictions (legacy)

But: conserver les visions (V3 + legacy V2/V1) sans qu’elles dictent l’exécution.

Règle:
- Les fichiers sous `knowledge/visions/` sont des **blueprints / visions**.
- Ils ne doivent **jamais** être utilisés comme “quoi faire maintenant”.
- En cas de divergence: **Checklist > Handoff > État réel observé > Handbook/archives > Visions legacy (V2/V1)**.

Pointeurs (à utiliser pour RAG / consultation):
- `knowledge/visions/LATEST_MASTER_CLEAN.md` (unifié, recommandé)
- `knowledge/visions/LATEST_CONTRADICTIONS.md` (contradictions extraites)
- `knowledge/visions/LATEST_V3.md` (structure V3)
- `knowledge/visions/LATEST_V2.md` et `knowledge/visions/LATEST_V1.md` (legacy)

Procédure quand une contradiction est détectée (ex: “Créer observed_snapshots” vs “existe déjà”):
1) Ne pas “corriger” les visions legacy en les réécrivant (on garde la traçabilité).
2) Ajouter/mettre à jour l’extrait dans `knowledge/visions/LATEST_CONTRADICTIONS.md`.
3) Si la résolution doit devenir canonique: réécrire la règle dans `operations/` (ERRATUM / checklist / handoff / doc canonique) et versionner.

