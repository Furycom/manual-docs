# README — Démarrage de session (canonique) (V5)

## Rôle (strictement opérationnel)
- Réponses minimales.
- Format imposé: **prochaines étapes brèves** + **où exécuter** + **commandes** + **quoi me renvoyer**.
- Aucun blabla.

## Interdictions
- Ne jamais commenter les mots de passe / tokens / clés / secrets visibles.
- Ignorer les bannières / artefacts / warnings non bloquants si le résultat demandé est atteint.

## Zéro placeholders
- Jamais de commandes contenant <...>, REPLACE_ME, YOUR_IP, etc.
- Si une info manque: d’abord commandes de collecte, ensuite seulement la commande finale.

## Méthode itérative (obligatoire)
1) Tu donnes un bloc de commandes.
2) Yann exécute.
3) Yann recopie uniquement la sortie demandée (COPYBACK).
4) Tu donnes le bloc suivant.
- Maximum 2 fronts en parallèle (2 blocs distincts), chaque bloc doit être exécutable immédiatement.

## Protocole Copyback (terminal) — obligatoire

### Objectif
Distinguer clairement:
- ce que Yann exécute
- ce que Yann renvoie (COPYBACK)
et éviter de recopier les commandes dans les logs.

### Helper standard: `bruce_block`
Le helper `bruce_block` encadre l’exécution et imprime des marqueurs visibles:

- `========== BRUCE COPYBACK BEGIN ==========`
- `=========== BRUCE COPYBACK END ===========`

Règle: Yann renvoie **uniquement** ce qui est entre BEGIN et END.

### Fichier helper
- Chemin: `tools/bruce_shell_helpers.sh`
- Contenu: fonction `bruce_block`

### Installation (référence)
Ajouter ceci dans `~/.bashrc` (déjà fait sur furymcp) :

```bash
source /home/furycom/manual-docs/tools/bruce_shell_helpers.sh
```

Puis recharger:

```bash
source ~/.bashrc
```

## Règle “full-file edit” (canonique)
Pour créer/modifier un fichier canonique:
- Toujours réécrire le fichier au complet (pas de patch partiel).
- Méthode standard: `nano <chemin>` puis copier-coller l’entièreté du fichier fourni.

## Smoke standard de début de session (obligatoire)

### Objectif
Avoir un point de départ stable et identique à chaque session:
- vérifs bornées MCP (health, openapi, endpoints principaux)
- trace minimale dans `memory/append` (source=ops)
- sortie facile à renvoyer (COPYBACK)

### Script canon
- Chemin: `tools/bruce_smoke.sh`
- Usage: exécuter **via** `bruce_block` et ne renvoyer que le COPYBACK.

Commande:

```bash
bruce_block <<'SH'
cd /home/furycom/manual-docs || exit 1
./tools/bruce_smoke.sh | sed -n '1,260p'
SH
```

Notes:
- Le script charge le token depuis le container `mcp-gateway` sans l’afficher.
- Le script utilise `GET /openapi.json` comme vérité des routes /bruce/*.
- TrueNAS peut remonter en “critical”; par défaut c’est **deferred** (voir CHECKLIST_LATEST).

## MCP-first: retrouver l’état sans “mémoire”
Quand une info est nécessaire (état, inventaire, jobs, derniers changements), priorité:
1) **MCP Gateway** (introspection / issues / RAG)
2) **Docs canoniques** (repo manual-docs)
3) Knowledge (infra / visions / archives)

### MCP Gateway (canon)
- Base: http://192.168.2.230:4000
- Health (sans auth): GET /health
- OpenAPI (sans auth): GET /openapi.json

### Auth MCP (pour endpoints protégés)
- Les endpoints /bruce/* peuvent exiger un token.
- Accepté: `Authorization: Bearer ...` OU `X-BRUCE-TOKEN: ...`
- Règle: ne jamais afficher le token dans la sortie.

### Endpoints MCP (référence actuelle via OpenAPI)
- GET /bruce/config/llm
- GET /bruce/introspect/docker/summary
- GET /bruce/introspect/last-seen
- GET /bruce/issues/open
- POST /bruce/memory/append
- POST /bruce/rag/search
- GET /bruce/rag/metrics
- POST /bruce/rag/context

### RAG (important)
- Payload JSON: champ `q` (pas `query`)
- `k` est optionnel

## Fichiers canoniques (repo)
Repo: `/home/furycom/manual-docs`

Entrées de départ (toujours):
- operations/INDEX_GLOBAL_LATEST.md
- operations/README_SESSION_GUIDE_LATEST.md
- operations/NEXT_SESSION_HANDOFF_LATEST.md
- operations/SESSION_LATEST.md
- operations/DOC_CANONICAL_GOVERNANCE_LATEST.md
- operations/INDEX_EMBEDDABLE_LATEST.md
- operations/CHECKLIST_LATEST.md
- operations/ERRATUM_LATEST.md

## Bornes / Safe-Termix
- Aucun scan lourd.
- Toujours borner les sorties (head, sed -n, tail, etc.).
- Toujours dire combien de lignes tu veux.

## Fin de session (discipline)
- Mettre à jour SESSION_LATEST.md (état + ce qui a changé).
- Produire/mettre à jour NEXT_SESSION_HANDOFF_V*.md (prochaines étapes).
- Ajuster les liens *_LATEST.md si une nouvelle version devient la référence.
- Commit git local si changement doc.
