# Session BRUCE — 2026-01-18 — Pack A + Pack B (préparation Pack C)

## PACK D — Doc canonique + knowledge + scope embeddable (2026-01-19)

- Repo docs versionné localement: /home/furycom/manual-docs (main)
- Canonique (8 fichiers) en place: /home/furycom/manual-docs/operations (CANONICAL_SET_LATEST.md)
- Schéma LATEST opérationnel: *_LATEST.md -> *_V*.md (sauf SESSION_LATEST.md)
- Knowledge importée et versionnée: /home/furycom/manual-docs/knowledge (sources embeddables)
- Index embeddable (scope + exclusions + pointeurs): INDEX_EMBEDDABLE_LATEST.md

---


## Contexte opérationnel

* Hôte : `furymcp` (LAN)
* MCP Gateway : `http://192.168.2.230:4000` (port `4000`)
* Token : `BRUCE_AUTH_TOKEN = bruce-secret-token-01`
* Contrainte critique de session :

  * Ne **jamais** arrêter/éteindre le conteneur **Termix** (outil d’accès principal à la CLI).
  * Appliquer systématiquement un style de commandes **safe-Termix** :

    * éviter les sorties volumineuses (ex. `docker logs`, `docker compose ps` en direct),
    * rediriger vers fichier + `head/tail` si nécessaire,
    * privilégier des outputs courts et bornés.

---

## PACK A — “Gateway propre et durable”

### Objectifs

1. Ajouter un endpoint **read-only** : `GET /bruce/config/llm`

   * Expose `base` + `model` (LLM) sans devoir relire les compose/env.
2. Durcir la surface RAG :

   * timeouts explicites (embedder + supabase),
   * limites de requête,
   * rate-limit minimal,
   * métriques (counters + latence) exposées via un endpoint protégé.

### Changements réalisés

#### A1) Nouveaux endpoints (protégés par token)

* `GET /bruce/config/llm`
  Réponse :
  { "ok": true, "base": "...", "model": "..." }

* `GET /bruce/rag/metrics`
  Réponse :

  * `started_at`
  * `rate_limited`
  * `search`: `{ calls, ok, err, last_ms, avg_ms, total_ms, last_error }`
  * `context`: idem

#### A2) Durcissement RAG

* Rate-limit in-memory par IP :

  * comportement validé (HTTP `429` à partir d’un certain nombre d’appels rapides)
  * header `Retry-After` prévu (visible lorsque réponse `429`)
* Timeouts explicites :

  * embedder (via `AbortController`)
  * supabase rpc (via `AbortController`)
* Limites sur les inputs :

  * `q` clampée (taille max), `k` clampé

#### A3) OpenAPI mis à jour

`/openapi.json` expose désormais :

* `/bruce/config/llm`
* `/bruce/rag/metrics`
* `/bruce/rag/search`
* `/bruce/rag/context`

### Implémentation (méthode utilisée)

* Source runtime : `/app/server.js` **dans le conteneur** `mcp-gateway`
* On a extrait `server.js` du conteneur, patché localement, recopié dans le conteneur puis redémarré.

Fichiers/artefacts créés :

* `/home/furycom/mcp-stack/patch_packA_server_js.py` (script de patch)
* `/home/furycom/mcp-stack/server.js` (version patchée)
* `/home/furycom/mcp-stack/server.js.bak_YYYYMMDD_HHMMSS` (backup)
* `/home/furycom/mcp-stack/_gateway_backups/` (snapshots)

### Commandes de validation (preuves)

OpenAPI :

* curl -sS [http://127.0.0.1:4000/openapi.json](http://127.0.0.1:4000/openapi.json) | grep -n "/bruce/config/llm|/bruce/rag/metrics|/bruce/rag/search|/bruce/rag/context"

Config LLM :

* curl -sS [http://127.0.0.1:4000/bruce/config/llm](http://127.0.0.1:4000/bruce/config/llm) -H "Authorization: Bearer bruce-secret-token-01" -H "Content-Type: application/json"

Métriques :

* curl -sS [http://127.0.0.1:4000/bruce/rag/metrics](http://127.0.0.1:4000/bruce/rag/metrics) -H "Authorization: Bearer bruce-secret-token-01" -H "Content-Type: application/json"

RAG search/context :

* curl -sS [http://127.0.0.1:4000/bruce/rag/search](http://127.0.0.1:4000/bruce/rag/search) -H "Authorization: Bearer bruce-secret-token-01" -H "Content-Type: application/json" -d '{"q":"test rag baseline","k":5}'
* curl -sS [http://127.0.0.1:4000/bruce/rag/context](http://127.0.0.1:4000/bruce/rag/context) -H "Authorization: Bearer bruce-secret-token-01" -H "Content-Type: application/json" -d '{"q":"test rag context baseline","k":3}'

Rate-limit :

* for i in $(seq 1 60); do code="$(curl -s -o /dev/null -w "%{http_code}" [http://127.0.0.1:4000/bruce/rag/search](http://127.0.0.1:4000/bruce/rag/search) -H "Authorization: Bearer bruce-secret-token-01" -H "Content-Type: application/json" -d '{"q":"rate limit test","k":1}')"; echo "$i $code"; done | tail -n 25

---

## PACK B — “RAG durable + commande unique embeddings (hors /tmp)”

### Objectifs

1. Sortir scripts et doc hors de `/tmp` et les ranger **dans le repo**.
2. Créer une **commande unique** qui :

   * détecte ce qui manque,
   * calcule les embeddings via l’embedder,
   * écrit en DB via le gateway (`/tools/supabase/exec-sql`),
   * produit un résumé court et loggable.

### Arborescence créée

* `tools/rag/`
* `tools/rag/_runs/` (logs d’exécution)
* `manual-docs/operations/rag/README.md` (doc opérationnelle)

### Fichiers Pack B livrés

* `tools/rag/bruce_rag_embed.py` : script Python
* `tools/rag/bruce_rag_embed.sh` : wrapper “commande unique”
* `manual-docs/operations/rag/README.md`

### Découverte importante (corrige un faux départ)

B0) Faux départ initial :

* Une détection pgvector a trouvé `mcp_memories.embedding`.
* Cela a fonctionné techniquement, mais ce n’est **pas** la cible principale du RAG.

B1) Cible RAG réelle (confirmée par SQL) :

* `public.bruce_chunks` : chunks (chunk_id, doc_id, chunk_index, texte)
* `public.bruce_embeddings` : embeddings pgvector (chunk_id, embedding)

Le script final (Pack B.1) :

* lit le texte depuis `bruce_chunks.text`
* upsert dans `bruce_embeddings (chunk_id, embedding)`

### Commande unique Pack B (usage)

* bash /home/furycom/mcp-stack/tools/rag/bruce_rag_embed.sh 200

Logs :

* /home/furycom/mcp-stack/tools/rag/_runs/

### État final (preuves)

* Missing embeddings (chunks without embedding) : 0
* SQL : missing = 0
* Commande batch 200 : “Nothing to do.”

Note : `/tools/supabase/exec-sql` n’accepte pas plusieurs statements dans un seul appel (pas de `;` multiples). Toujours 1 statement par requête.

---

## Incidents / contraintes rencontrées pendant la session

1. Éjections SSH :

* Certaines commandes “bruyantes” et certains appels Docker ont provoqué des éjections de session dans Termix.
* Contournement : style safe-Termix, outputs courts et bornés.

2. Arrêt involontaire de Termix (incident) :

* Termix a été arrêté par erreur et l’accès CLI a été coupé.
* Correction : Termix relancé.
* Règle stricte : ne plus jamais stopper Termix.

---

## État du système à la fin de la session (résumé)

* Pack A : Done (config LLM + durcissement RAG + metrics + OpenAPI OK)
* Pack B : Done (Pack B.1) — embeddings RAG réels complets (missing = 0) + commande incrémentale prête

---

## PACK C — “Command Queue durcie” (terminé et validé)

### Objectif
Rendre l’exécution de commandes distante **prévisible, bornée et auditée** :
- allowlist stricte (pas de shell libre)
- timeouts par exécution
- stdout/stderr bornés (troncature explicite)
- résultat structuré et compact en base (bruce_cmd_result)

### État final (preuves observées)
- Allowlist active (code : ALLOWED_EXACT / ALLOWED_SYSTEMD_SERVICES / ALLOWED_JOURNAL_UNITS / ALLOWED_SYSTEMCTL_SHOW_PROPS).
- Rejet effectif des commandes hors allowlist :
  - `uname -a` => `status=rejected`, `allow_detail=not_in_allowlist` (ex. cmd_id 98).
  - `id` => `status=rejected`, `allow_detail=not_in_allowlist` (ex. cmd_id 87).
- Commande autorisée (contrôle positif) :
  - `systemctl is-active bruce-cmd-worker.service` => `status=done`, `allow_detail=allowed_systemctl_is_active` (ex. cmd_id 97).
- Troncature validée :
  - un run `journalctl ... -n 500` a produit `out_trunc=1` et un préfixe `[TRUNCATED: ...]` (ex. cmd_id 75).

### Snapshot (artefact)
- `/home/furycom/manual-docs/operations/_snapshots/packC_cmd_queue_20260119_175041.tgz`

### Fichiers “source of truth”
- `/home/furycom/mcp-stack/bruce_cmd_worker.py`
- `/home/furycom/mcp-stack/bruce_cmd_enqueue.py`
- `/home/furycom/mcp-stack/bruce_cmd_results_tail.py`
- `/etc/systemd/system/bruce-cmd-worker.service`

### Limites actuelles (assumées)
- Toute commande non explicitement allowlistée est rejetée (`not_in_allowlist`).
- Les sorties volumineuses sont tronquées (objectif : éviter les éjections Termix/SSH et garder des logs exploitables).

---

## PACK D — prochain incrément minimal (à décider, pas d’exécution automatique)

D1) Élargir ou non `ALLOWED_SYSTEMD_SERVICES` (liste minimale uniquement).
D2) Autoriser ou non `systemctl status` pour certains timers (au strict nécessaire).
D3) Stabiliser `LOOP_SLEEP` (valeur fixe) ou conserver l’actuel.

