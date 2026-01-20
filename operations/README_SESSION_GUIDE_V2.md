# README — Démarrage de session (canonique) (V2)

## Rôle (strictement opérationnel)
- Réponses minimales.
- Format imposé: **où exécuter + commandes + quoi me renvoyer**.
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
3) Je recopie la sortie.
4) Tu donnes le bloc suivant.
- Maximum 2 fronts en parallèle (2 blocs distincts), chaque bloc doit être exécutable immédiatement.

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

### Endpoints MCP (référence actuelle via OpenAPI)
- GET /bruce/introspect/docker/summary
- GET /bruce/introspect/last-seen
- GET /bruce/issues/open
- POST /bruce/memory/append
- POST /bruce/rag/search
- GET /bruce/rag/metrics
- POST /bruce/rag/context
- GET /bruce/config/llm

## Fichiers canoniques (repo)
Repo: /home/furycom/manual-docs

Entrées de départ (toujours):
- operations/INDEX_GLOBAL_LATEST.md
- operations/README_SESSION_GUIDE_LATEST.md
- operations/NEXT_SESSION_HANDOFF_LATEST.md
- operations/SESSION_LATEST.md
- operations/DOC_CANONICAL_GOVERNANCE_LATEST.md
- operations/INDEX_EMBEDDABLE_LATEST.md
- operations/CHECKLIST_LATEST.md

Ordre de vérité (anti-contradictions)
1) Checklist
2) Next Session Handoff
3) État réel observé (MCP / collectors)
4) Handbook / archives
5) Visions legacy

## Bornes / Safe-Termix
- Aucun scan lourd.
- Toujours borner les sorties (head, sed -n, tail, etc.).
- Toujours dire combien de lignes tu veux.

## Fin de session (discipline)
- Mettre à jour SESSION_LATEST.md (état + ce qui a changé).
- Produire/mettre à jour NEXT_SESSION_HANDOFF_V*.md (prochaines étapes).
- Ajuster les liens *_LATEST.md si une nouvelle version devient la référence.
- Commit local (git) si changement doc.

## Note: “mcp-manual” MkDocs (legacy)
- Service legacy exposé sur :8181 (mkdocs).
- Il est **déjà** dans la checklist comme futur “decommission”.
- Ne pas le retirer tant que la doc canonique + MCP introspection couvrent le besoin.
