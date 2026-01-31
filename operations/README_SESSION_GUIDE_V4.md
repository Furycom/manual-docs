# README — Démarrage de session (canonique) (V4)

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
2) J’exécute.
3) Je recopie la sortie demandée (COPYBACK).
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

Yann doit **renvoyer uniquement** ce qui est entre BEGIN et END.

### Installation (référence)
Le fichier helper est:
- `/home/furycom/manual-docs/tools/bruce_shell_helpers.sh`

Activation dans la session:
```bash
source /home/furycom/manual-docs/tools/bruce_shell_helpers.sh
```

Option (persistant) : ajouter la ligne ci-dessus dans `~/.bashrc` (hors repo).

### Usage standard (modèle)
```bash
bruce_block <<'SH'
cd /home/furycom/manual-docs || exit 1
# commandes...
SH
```

## Règle d’édition des fichiers (canon — obligatoire)
Quand on doit créer/modifier un fichier dans le repo:

1) Toujours ouvrir le fichier avec nano (chemin complet).
2) L’assistant fournit **le fichier complet**.
3) Yann remplace tout le contenu, sauvegarde, sort.
4) Ensuite seulement: permissions (si nécessaire), puis git add/commit.

Règle: **jamais de patch partiel** (pas de sed/awk/python pour injecter des bouts).  
Exception: opérations git standard (symlink `_LATEST`, git restore, rm d’un fichier parasite).

## Git: règle simple (anti-erreur)
Avant toute commande git:
```bash
cd /home/furycom/manual-docs || exit 1
```

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
- Règle: **ne jamais afficher le token dans la sortie**.
- Pour exécuter des curls auth en session SSH:
  - extraire le token depuis le container `mcp-gateway` dans une variable, puis l’utiliser en header (sans echo).

#### Token (extraction safe — NE PAS PRINT)
```bash
TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' | tr -d '\r\n')"
[ -n "$TOKEN" ] && echo "[OK] token loaded len=$(printf %s "$TOKEN" | wc -c | tr -d ' ')"
```

### Endpoints MCP (référence actuelle via OpenAPI)
La vérité des endpoints = `GET /openapi.json`.

* GET /bruce/config/llm
* GET /bruce/introspect/docker/summary
* GET /bruce/introspect/last-seen
* GET /bruce/issues/open
* POST /bruce/memory/append
* POST /bruce/rag/search
* POST /bruce/rag/context
* GET /bruce/rag/metrics

## RAG (important)
* Payload JSON: champ `q` (pas `query`)
* `k` est optionnel

### RAG search (retourne un tableau JSON)
```bash
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "http://192.168.2.230:4000/bruce/rag/search" \
  --data '{"q":"NEXT_SESSION_HANDOFF_LATEST","k":3}' \
  | sed -n '1,220p'
```

### RAG context (retourne {ok:true,...} + champ context)
```bash
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "http://192.168.2.230:4000/bruce/rag/context" \
  --data '{"q":"INDEX_GLOBAL_LATEST","k":3}' \
  | sed -n '1,260p'
```

## Memory append (rappel schema minimal)
- `source` requis
- `content` requis pour insérer une note utile

Exemple:
```bash
curl -sS --max-time 15 -H "X-BRUCE-TOKEN: ${TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST "http://192.168.2.230:4000/bruce/memory/append" \
  --data '{"source":"ops","channel":"ops","content":"note","tags":["session"]}' \
  | sed -n '1,120p'
```

## Fichiers canoniques (repo)
Repo: /home/furycom/manual-docs

Entrées de départ (toujours):
* operations/INDEX_GLOBAL_LATEST.md
* operations/README_SESSION_GUIDE_LATEST.md
* operations/NEXT_SESSION_HANDOFF_LATEST.md
* operations/SESSION_LATEST.md
* operations/DOC_CANONICAL_GOVERNANCE_LATEST.md
* operations/INDEX_EMBEDDABLE_LATEST.md
* operations/CHECKLIST_LATEST.md
* operations/ERRATUM_LATEST.md

Ordre de vérité (anti-contradictions)
1. Checklist
2. Next Session Handoff
3. État réel observé (MCP / collectors)
4. Erratum
5. Handbook / archives
6. Visions legacy

## Bornes / Safe-Termix
* Aucun scan lourd.
* Toujours borner les sorties (head, sed -n, tail, etc.).
* Toujours dire combien de lignes tu veux.

## Fin de session (discipline)
* Mettre à jour SESSION_LATEST.md (état + ce qui a changé).
* Produire/mettre à jour NEXT_SESSION_HANDOFF_V*.md (prochaines étapes).
* Ajuster les liens *_LATEST.md si une nouvelle version devient la référence.
* Commit git local (git) si changement doc.

## Note: “mcp-manual” MkDocs (legacy)
* Service legacy exposé sur :8181 (mkdocs).
* Il est **déjà** dans la checklist comme futur “decommission”.
* Ne pas le retirer tant que la doc canonique + MCP introspection couvrent le besoin.
