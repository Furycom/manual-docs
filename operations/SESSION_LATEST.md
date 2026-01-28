# SESSION LATEST — 2026-01-28

## Resume
- Correction BRUCE-only: faux “missing_expected” pour des services attendus sur `mcp-gateway` et `furyssh`.
- Cause racine: les attendus docker provenaient de `docker_service_intent` (seeded) avec des hostnames historiques/non collectés:
  - `mcp-gateway/*` alors que ces containers sont observés sur `furymcp`.
  - `furyssh/*` alors qu’aucun snapshot docker n’a jamais existé pour `furyssh` (collector non branché / hostname non observé).
- Fix appliqué: mise à jour de `docker_service_intent`:
  - `mcp-gateway/*` mis à `retired` (doublons, car `furymcp/*` existe déjà).
  - `furyssh/*` mis à `retired` (hostname non collecté; `speaches` non observé).
- Résultat vérifié:
  - MCP `/bruce/issues/open`: plus aucun issue `docker/*`.
  - Restant: uniquement TrueNAS (deferred).

## Etat MCP (observe)
- Base MCP: http://192.168.2.230:4000
- Health (dernier connu):
  {"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-28T14:07:49.198Z"}

## Issues MCP (etat actuel)
- TrueNAS uniquement (deferred, hors BRUCE):
  - critical: pool `RZ1-5TB-4X` DEGRADED (code=FAILING_DEV)
  - warning: services STOPPED (glusterd, iscsitarget, nfs, snmp, ups)

## Clarification importante (vues attendus)
- `public.v_expected_docker_services_effective` n’est pas “enforced” au sens filtré; elle expose la chaîne enrichie (incluant `retired`).
- Pour une vue réellement “enforced”, on a ajouté:
  - `public.v_expected_docker_services_enforced` = `active` + `enforce_after <= now()`.

## Notes (bornes)
- Les vues docker attendues-vers-observées appartiennent à `supabase_admin`.
- Connexion DB `supabase_admin` possible via `POSTGRES_PASSWORD` dans le container `supabase-db` (ne jamais afficher les secrets).
