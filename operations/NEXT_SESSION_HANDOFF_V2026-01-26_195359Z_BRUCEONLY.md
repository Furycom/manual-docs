# NEXT SESSION HANDOFF — 2026-01-26 (BRUCE-ONLY)

## Objectif (prochaine session)
- Démarrer MCP-first.
- Se concentrer uniquement sur BRUCE (docker expected/observed + collectors + MCP health).
- Ne pas traiter TrueNAS dans cette session (deferred).

## Meilleure prochaine action (BRUCE-only)
Priorité: corriger l’issue CRITICAL `SERVICE_MISSING`:
- host: furycomai
- container attendu: youthful_pike
But: comprendre pourquoi il est “expected running” mais “observed missing”.

## Séquence de démarrage — 1 bloc
Sur `furymcp` :
1) `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Vérifier les issues : `/bruce/issues/open` puis isoler uniquement l’item docker.
3) Diagnostiquer sur `furycomai` : état Docker + présence du container + raisons (rename, compose absent, host down, collector stale).

