
# SESSION LATEST — 2026-01-31

## Résumé
- Protocole “COPYBACK” opérationnel:
  - Helper `bruce_block` installé (bornes BEGIN/END) pour éviter de recopier les commandes dans les logs.
  - Règle: Yann renvoie uniquement ce qui est entre BEGIN et END.
- Démarrage de session standardisé:
  - Nouveau script `tools/bruce_smoke.sh` (smoke borné + vérif issues + memory/append).
  - Le README canonique exige maintenant de lancer `tools/bruce_smoke.sh` au début de chaque session.
- Vérité API MCP confirmée:
  - Les endpoints actifs sont ceux de `GET /openapi.json` (8 routes /bruce/*).
  - `/bruce/introspect/observed/*` = legacy (non exposé par le gateway actuel).
- Politique TrueNAS confirmée:
  - L’alerte pool `RZ1-5TB-4X` DEGRADED/FAILING_DEV reste **critique** mais est **deferred par défaut** (ne pas traiter sans demande explicite de Yann).

## État MCP (observé)
- Base: http://192.168.2.230:4000
- OpenAPI /bruce/* (8):
  - /bruce/config/llm
  - /bruce/introspect/docker/summary
  - /bruce/introspect/last-seen
  - /bruce/issues/open
  - /bruce/memory/append
  - /bruce/rag/search
  - /bruce/rag/context
  - /bruce/rag/metrics

## Notes / règles importantes
- Memory append:
  - Schéma `MemoryAppendRequest`: champ `source` requis; `content` requis en pratique (sinon erreur “Missing content”).
- TrueNAS:
  - Critique conservée; hors-scope des sessions BRUCE par défaut.

## Canon modifié aujourd’hui
- `operations/README_SESSION_GUIDE_LATEST.md` -> V5 (ajoute `bruce_smoke` comme démarrage obligatoire).
- `operations/ERRATUM_LATEST.md` -> V3 (ajoute COPYBACK + règle “full-file edit”).
- `operations/CHECKLIST_LATEST.md` -> V3 (règle TrueNAS critique mais deferred).
- Ajouts:
  - `tools/bruce_shell_helpers.sh` (bruce_block)
  - `tools/bruce_smoke.sh` (smoke standard)
