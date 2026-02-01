# RUNBOOK — RAG Embeddings (V2)
Date (UTC): 2026-01-20
But: Décrire exactement comment relancer l’embed RAG et comment vérifier que ça a marché, en mode safe-Termix.

## Composants (réel)
- Repo: `/home/furycom/mcp-stack`
- Scripts:
  - `tools/rag/bruce_rag_embed.sh` (run manuel, log dans `_runs/`)
  - `tools/rag/bruce_rag_embed.py` (embed + upsert SQL via Gateway)
  - `tools/rag/run_rag_embed_daily.sh` (run quotidien via systemd)
- Logs: `tools/rag/_runs/*.log`
- Systemd:
  - `bruce-rag-embed.timer` (OnCalendar `03:15:00` UTC)
  - `bruce-rag-embed.service` (ExecStart `.../tools/rag/run_rag_embed_daily.sh`)

## Scope indexé (doc)
Voir: `INDEX_EMBEDDABLE_LATEST.md` (operations + knowledge, exclusions par défaut).

## Pré-requis (sanity check)
1) Timer présent et actif:
- `systemctl status bruce-rag-embed.timer --no-pager -l | head -n 40`
- `systemctl list-timers --all | grep bruce-rag-embed || true`

2) Accès Gateway (exec-sql) et embedder (via env par défaut dans scripts):
- Gateway par défaut: `http://127.0.0.1:4000`
- Token: variable d’environnement `BRUCE_AUTH_TOKEN` dans le conteneur `mcp-gateway` (extraction dynamique)

### Snippet AUTH (canon, sans placeholders)
Exécuter depuis l’host (`furymcp`). Le conteneur `mcp-gateway` peut ne pas avoir `curl`.

```bash
BRUCE_TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null || true)"
test -n "$BRUCE_TOKEN"
curl -fsS --connect-timeout 2 --max-time 10 \
  -H "Authorization: Bearer $BRUCE_TOKEN" \
  http://127.0.0.1:4000/bruce/rag/metrics | head -n 60
```
- Embedder par défaut: `http://192.168.2.85:8081`

## Relancer l’embed (manuel, safe)
Commande recommandée (limite bornée):
- `cd /home/furycom/mcp-stack`
- `./tools/rag/bruce_rag_embed.sh 50`

Notes:
- Le script écrit un log: `tools/rag/_runs/run_YYYYMMDD_HHMMSS.log`
- Il imprime ensuite un tail borné (max 60 lignes).

## Vérifier les résultats (safe)
### A) Lire le dernier log (borné)
- `cd /home/furycom/mcp-stack`
- `L="$(ls -1t tools/rag/_runs/*.log | head -n 1)"; echo "$L"; tail -n 80 "$L" || true`

### B) Vérifier le “missing embeddings” via Gateway (borné)
- `curl -sS -H "Authorization: Bearer $BRUCE_TOKEN" -H "Content-Type: application/json" \
  -d '{"sql":"select count(*)::int as missing from public.bruce_chunks c left join public.bruce_embeddings e on e.chunk_id=c.chunk_id where e.embedding is null;"}' \
  http://127.0.0.1:4000/tools/supabase/exec-sql | head -c 900; echo`

Interprétation:
- `missing` doit diminuer après un run (ou être 0 si tout est déjà embeddé).

## Relance automatique (quotidien)
Le job quotidien est géré par:
- `bruce-rag-embed.timer` -> `bruce-rag-embed.service` -> `tools/rag/run_rag_embed_daily.sh`

Vérifier dernier run:
- `systemctl status bruce-rag-embed.service --no-pager -l | head -n 80`

## En cas d’échec (minimum)
1) Vérifier que la Gateway répond:
- `curl -sS -H "Authorization: Bearer $BRUCE_TOKEN" -H "Content-Type: application/json" \
  -d '{"sql":"select 1 as ok;"}' http://127.0.0.1:4000/tools/supabase/exec-sql | head -c 300; echo`

2) Vérifier que l’embedder répond:
- `curl -sS -H "Content-Type: application/json" -d '{"inputs":"ping","max_length":32}' \
  http://192.168.2.85:8081/embed | head -c 500; echo`

3) Lire le dernier log (section A).

---

## Preuves Supabase (canon, safe)

But: prouver que la memoire + chunks + embeddings existent et sont a jour, et que le pipeline RAG n'a pas de retard.

### Commandes (depuis furymcp; ne pas afficher le token)

BRUCE_TOKEN="$(docker exec mcp-gateway sh -lc 'printf %s "$BRUCE_AUTH_TOKEN"' 2>/dev/null || true)"
test -n "$BRUCE_TOKEN"

curl -fsS --connect-timeout 2 --max-time 12 \
  -H "Authorization: Bearer $BRUCE_TOKEN" \
  -H "Content-Type: application/json" \
  --data-raw '{"sql":"select (select count(*) from public.bruce_chunks)::int as chunks, (select count(*) from public.bruce_embeddings)::int as embeddings, (select count(*) from public.bruce_memory_journal)::int as journal_rows, (select max(ts) from public.observed_snapshots) as observed_last_ts, (select max(created_at) from public.bruce_memory_journal) as journal_last_ts, (select count(*) from public.bruce_chunks c left join public.bruce_embeddings e on e.chunk_id=c.chunk_id where e.chunk_id is null)::int as missing_embeddings;"}' \
  "http://192.168.2.230:4000/tools/supabase/exec-sql" \
  | head -c 1600; echo

### Interpretation attendue

- missing_embeddings doit etre 0 (ou tres faible si un embed run est en cours).
- embeddings doit etre >= chunks (en pratique egal si un seul modele).
- observed_last_ts doit etre recent (sondes internes actives).

## Mise à jour (2026-01-31) — Ingestion du journal (bruce_memory_journal)

Le job quotidien ne fait pas seulement l’ingest des fichiers `manual-docs`.
Il ingère aussi le contenu de `public.bruce_memory_journal` dans `bruce_docs/bruce_chunks` (source=`journal`), puis calcule les embeddings manquants.

Chaîne quotidienne (furymcp):
- `bruce-rag-embed.timer` -> `bruce-rag-embed.service` -> `tools/rag/run_rag_embed_daily.sh`
- Étapes: sync manual-docs -> ingest manual-docs -> ingest journal -> embed
