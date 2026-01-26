# NEXT SESSION HANDOFF — 2026-01-26 (A)

## Objectif (prochaine session)
- Démarrer “MCP-first” : vérifier l’état via MCP, puis choisir UNE action suivante claire et exécutable.
- Assurer que la doc canonique reflète l’état actuel (pointeurs LATEST cohérents).

## État actuel (confirmé)
- `operations/README_SESSION_GUIDE_LATEST.md` -> `README_SESSION_GUIDE_V3.md` (commité).
- Script `./bootstrap.sh` (sur /home/furycom) : OK
  - Health + OpenAPI OK
  - Endpoints protégés OK
  - Smoke RAG OK (search/context)

## Point d’attention (issues MCP ouvertes)
- CRITICAL: TrueNAS pool `RZ1-5TB-4X` = DEGRADED (FAILING_DEV).
- CRITICAL: Docker attendu manquant sur `furycomai` : container `youthful_pike` (Expected running, Observed missing).
- WARNING: services TrueNAS STOPPED (glusterd, iscsitarget, nfs, snmp, ups) — à traiter seulement si requis.

## Séquence de démarrage (next session) — 1 bloc
Sur `furymcp` :
1) Exécuter :
   - `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Lire la sortie et décider :
   - soit on attaque le pool TrueNAS (diagnostic disque / resilver / statut),
   - soit on corrige l’expected/observed (pourquoi `youthful_pike` est attendu sur furycomai).

## Règles
- Safe-Termix : sorties bornées.
- Zéro placeholders.
- Ne jamais afficher de secrets/tokens.
