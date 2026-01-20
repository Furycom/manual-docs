# CHECKLIST — Canonique (V2)

## Portée
Documentation et versionning local uniquement (homelab).

## Invariants (à ne pas casser)
- Maintenir les 8 fichiers *_LATEST.md cohérents.
- Conserver les versions *_V*.md sans perte (immutables).
- Les sorties doivent rester bornées (safe-Termix).
- Pas de “scan lourd” sans raison.

## À faire (à maintenir)
- [ ] Garder les pointeurs *_LATEST.md à jour après chaque modification stable.
- [ ] Archiver les snapshots pertinents dans _snapshots/ quand une étape importante est terminée.
- [ ] Garder INDEX_EMBEDDABLE_LATEST.md cohérent (ajouts / retraits).

## Backlog (priorité basse, mais réel)

- [ ] Decommission: retirer le service Docker `mcp-manual` (MkDocs :8181) quand on sera prêt.
      Pré-requis: la doc canonique doit couvrir tous les besoins + MCP introspection (read-only) doit être suffisante.
      Notes:
      - Ne PAS faire maintenant.
      - Objectif: réduire la dette (service “manuel” ancien) et basculer sur le système vivant (Supabase/MCP/collectors).
      - Le retrait doit être planifié, testé, et documenté (rollback clair).
