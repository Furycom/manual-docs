# DOC CANONICAL GOVERNANCE — V1
Date (UTC): 2026-01-19T19:26:29Z
But: Tout ce qui guide BRUCE (plans, checklists, handoffs, décisions) doit vivre DANS le Home Lab, être versionné, et rester retrouvable.

## Objectif (non négociable)
- Zéro “source of truth” sur le bureau local : tout est dans le repo du homelab.
- Les décisions et prochaines étapes sont écrites et maintenues (pas seulement “dans la tête”).
- Tout nouveau fichier/idéation externe reçu est comparé, puis intégré proprement (sans perte) dans la doc canonique.

## Emplacement canonique (actuel)
- Racine doc ops: /home/furycom/manual-docs/operations

## Fichiers canoniques (minimum)
- SESSION_LATEST.md : état consolidé le plus récent (copie identique au dernier pack)
- NEXT_SESSION_HANDOFF_V1.md : objectifs + séquence courte + décisions à prendre (prochaine session)
- _snapshots/ : archives tgz datées (preuves et gel d’état)

## Règles de maintenance
1) Toute modification de comportement/architecture => mise à jour immédiate de la doc canonique.
2) Toute session finit par :
   - mise à jour SESSION_LATEST.md (si nécessaire)
   - mise à jour NEXT_SESSION_HANDOFF (toujours)
   - snapshot _snapshots/ si un “pack” est terminé
3) Si un ancien fichier de checklist est fourni :
   - il n’est PAS source de vérité
   - il sert uniquement à détecter des tâches manquantes à réintégrer dans la doc canonique

## Pack D (à réaliser ensuite) — Documentation versionnée + retrouvable
- D1) Git local pour versionner manual-docs (commits courts, tags “pack done”)
- D2) Index doc (fichier INDEX.md) + conventions de nommage
- D3) Ingestion RAG automatique de la doc canonique (chunks/embeddings) après commit
- D4) Procédure de comparaison : “nouveau fichier externe” => diff => intégration contrôlée

Fin.
