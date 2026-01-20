# INDEX — Embeddable Scope (V2)
Date (UTC): 2026-01-20
But: Définir noir sur blanc ce qui est indexé (RAG) et ce qui est exclu, avec pointeurs LATEST utiles.

## Scope embeddable (par défaut)
Le RAG peut indexer:

### Canonique (ops)
- `/home/furycom/manual-docs/operations/*.md`
  - Inclure: docs canoniques + index
  - Exclure: preuves/snapshots (voir exclusions)

### Knowledge
- `/home/furycom/manual-docs/knowledge/**/*.md`
- `/home/furycom/manual-docs/knowledge/**/*.txt`
- `/home/furycom/manual-docs/knowledge/**/*.json`

## Exclusions par défaut (non embeddable)
- `operations/_snapshots/*.tgz`
- Bruit d’exécution: `__pycache__/`, `*.pyc`, `*.log`, `*.tmp`
- Artefacts de sauvegarde: `*.bak_*`
- Secrets/config: `*.env`, `*.key`, `*.pem`, `*.token`, et tout sous `.ssh/`

## Pointeurs LATEST — canonique (démarrage)
Dossier: `/home/furycom/manual-docs/operations`

- `SESSION_LATEST.md` (fichier direct)
- `NEXT_SESSION_HANDOFF_LATEST.md` (symlink)
- `README_SESSION_GUIDE_LATEST.md` (symlink)
- `DOC_CANONICAL_GOVERNANCE_LATEST.md` (symlink)
- `CHECKLIST_LATEST.md` (symlink)
- `PLAN_LATEST.md` (symlink)
- `BLUEPRINT_LATEST.md` (symlink)
- `ERRATUM_LATEST.md` (symlink)
- `CANONICAL_SET_LATEST.md` (symlink)

## Pointeurs LATEST — knowledge (sources)
Dossier: `/home/furycom/manual-docs/knowledge`

- `knowledge/mcp-manual/LATEST.md` et `LATEST.txt`
- `knowledge/mcp-manual/exports/` (historiques md/txt)
- `knowledge/mcp-manual/extra/` (notes docs additionnelles)
- `knowledge/mcp-stack-docs/LATEST.md` (ex: API gateway)
- `knowledge/mcp-manual-archive/exports/` (json/raw.json)
- `knowledge/sessions/LATEST.md` (notes de session)
- `knowledge/discovery/LATEST.txt` (dernière découverte)

## Règle d’évolution
- Si une source devient “canonique”: réécrire dans `operations/` (nouvelle version `*_V*.md`) puis repointer `*_LATEST.md`.
- Sinon: rester dans `knowledge/` avec `LATEST.*` + historiques en `exports/`.

## Pointeurs LATEST — knowledge (infra)
Dossier: `/home/furycom/manual-docs/knowledge/infra`

- `knowledge/infra/LATEST.md` (delta infra le plus récent)
- `knowledge/infra/exports/` (historiques infra)

## Pointeurs LATEST — visions (blueprints / architecture)
Dossier: `/home/furycom/manual-docs/knowledge/visions`

- `knowledge/visions/LATEST_MASTER.md` (unifié, V3 + legacy)
- `knowledge/visions/LATEST_MASTER_CLEAN.md` (unifié, version propre)
- `knowledge/visions/LATEST_CONTRADICTIONS.md` (contradictions extraites, court)
- `knowledge/visions/LATEST_V3.md` (structure V3)
- `knowledge/visions/LATEST_V2.md` (legacy)
- `knowledge/visions/LATEST_V1.md` (legacy)
- `knowledge/visions/exports/` (historiques figés datés)

