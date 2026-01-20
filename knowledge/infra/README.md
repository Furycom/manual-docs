# knowledge/infra

But: stocker des documents “infra” **embeddables** qui décrivent l’**état réel** (inventaire/structure/endpoints), sans toucher au canonique ops.

## Règles
- La référence “infra la plus à jour” se lit via `knowledge/infra/LATEST.md`.
- Toute mise à jour = **nouveau fichier daté** dans `knowledge/infra/exports/` + repointage `LATEST.md` et mise à jour de `LATEST.txt` + commit.

## Pointeurs
- `LATEST.md` : symlink vers le snapshot infra “Full” le plus récent
- `LATEST.txt` : nom du snapshot de référence (une ligne)
- `exports/` : historiques figés datés (snapshots Full + patchs)
- `exports/INFRA_PATCH_*.md` : patchs/deltas courts (validations rapides, changements ponctuels)
- `exports/_bad/` : artefacts/ébauches non retenus (ne pas référencer, ne pas indexer comme vérité)

