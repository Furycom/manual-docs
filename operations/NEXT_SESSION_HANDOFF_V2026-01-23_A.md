# NEXT SESSION HANDOFF — 2026-01-23 (A)

## Objectif initial
- Débloquer le pipeline RAG embeddings (bruce_rag_embed.py) qui échouait car la fonction SQL `public.exec_sql_write(text)` n’existait pas.

## État actuel (résultat)
- OK: `public.exec_sql_write(query text)` a été créée dans Postgres (container `supabase-db`).
- OK: `bruce_rag_embed.py --limit 50` = 50/50 embeddings écrits (dims=1024).
- OK: SSH sans mot de passe depuis `furymcp` vers `supabase` fonctionne (clé `~/.ssh/id_ed25519` installée côté serveur via `ssh-copy-id -f`).

## Cause racine (RAG)
- Le gateway appelait `public.exec_sql_write(text)` mais la fonction n’existait pas dans Postgres => erreurs 404 / 42883.

## Notes importantes
- Ne pas utiliser `supabase-db-forward` pour psql: `psql` n’y est pas; utiliser `supabase-db`.
- Les erreurs précédentes de `exec_sql_write(select 1::text)` venaient d’un quoting qui supprimait les quotes autour de 'select 1'.
