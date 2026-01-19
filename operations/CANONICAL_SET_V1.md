# Set canonique — 8 fichiers (V1)

## Emplacement unique (source of truth)
`/home/furycom/manual-docs/operations`

## Les 8 fichiers canoniques (noms EXACTS)
1) `SESSION_LATEST.md`
   - Rôle: résumé global à jour (objectif de session, état, invariants, décisions récentes).
   - Statut: fichier direct (pas de symlink).

2) `NEXT_SESSION_HANDOFF_LATEST.md`
   - Rôle: priorités strictes + séquence courte exécutable (1 bloc à la fois).
   - Implémentation: symlink vers la dernière version `NEXT_SESSION_HANDOFF_V*.md`.

3) `README_SESSION_GUIDE_LATEST.md`
   - Rôle: procédure de démarrage standard (3 étapes max) + règles de session.
   - Implémentation: symlink vers `README_SESSION_GUIDE_V*.md`.

4) `DOC_CANONICAL_GOVERNANCE_LATEST.md`
   - Rôle: gouvernance des docs (règles de versionning, conventions, invariants).
   - Implémentation: symlink vers `DOC_CANONICAL_GOVERNANCE_V*.md`.

5) `CHECKLIST_LATEST.md`
   - Rôle: checklist canonique (documentation/versionning uniquement).
   - Implémentation: symlink vers `CHECKLIST_V*.md`.

6) `PLAN_LATEST.md`
   - Rôle: plan de travail docs (objectifs, principes, portée).
   - Implémentation: symlink vers `PLAN_V*.md`.

7) `BLUEPRINT_LATEST.md`
   - Rôle: blueprint minimal (structure des dossiers, inventaire des éléments, liens).
   - Implémentation: symlink vers `BLUEPRINT_V*.md`.

8) `ERRATUM_LATEST.md`
   - Rôle: corrections/décisions durables (log court, daté).
   - Implémentation: symlink vers `ERRATUM_V*.md`.

## Notes
- Les fichiers `*_V*.md` sont les versions figées.
- Les artefacts `*.bak_*` restent hors canon; à exclure du cycle de démarrage.
