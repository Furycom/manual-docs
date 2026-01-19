## Session 2026-01-18 — Cloture (Pack B: durabilite embeddings)

DONE
- Backfill embeddings complet (17/17) avec embedder http://192.168.2.85:8081/embed (inputs), model BAAI/bge-m3, dims 1024.
- Migration DB bruce_embeddings: PK (chunk_id, model), embedding vector(1024), index HNSW filtre sur model='BAAI/bge-m3'. Table bruce_embeddings_old conservee (rollback).
- Validation Gateway RAG: /bruce/rag/search + /bruce/rag/context + /bruce/rag/metrics OK.

NEXT
- (Optionnel) drop bruce_embeddings_old apres fenetre de securite.
