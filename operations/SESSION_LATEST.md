# SESSION LATEST — 2026-01-28

## Resume
- Correction BRUCE-only: faux “missing_expected” pour `furymcp/dashy`.
- Cause: `v_docker_expected_vs_observed_latest` + `v_docker_expected_issues_latest` pointaient sur `observed_docker_containers_latest` (source `docker_facts_v1`), stale pour `furymcp` (dernier: 2025-12-30).
- Fix appliqué: vues repointées sur `public.bruce_observed_docker_containers_latest` (source BRUCE `docker`, à jour).
- Résultat vérifié: `furymcp/dashy` = `ok (running)` et n’apparaît plus dans `v_docker_expected_issues_latest`.

## Etat MCP (observe)
- Base MCP: http://192.168.2.230:4000
- Health (dernier):
  {"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-28T14:07:49.198Z"}

## Issues MCP (snapshot)
- counts: critical=13 warning=5
- critical (BRUCE/docker): `SERVICE_MISSING` pour hosts `mcp-gateway` (plusieurs services) et `furyssh` (dozzle-agent, speaches).
  Note: ces hosts n’apparaissent pas dans `docker summary` ni dans `last-seen` pour `source_id=docker` (probable mismatch de hostname / attendus obsoletes / host non collecté).
- critical (hors BRUCE): TrueNAS pool `RZ1-5TB-4X` DEGRADED (deferred).
- warning (hors BRUCE): services TrueNAS STOPPED (glusterd, iscsitarget, nfs, snmp, ups).

## Meilleure prochaine action (BRUCE-only)
- Auditer `expected_docker_services` pour `hostname in ('mcp-gateway','furyssh')` et corriger/désactiver les attendus qui génèrent des faux CRITICAL (car non observés par le collector `docker`).

## Notes (bornes)
- Les vues docker attendues-vers-observées appartiennent à `supabase_admin`.
- Connexion DB `supabase_admin` possible via `POSTGRES_PASSWORD` dans le container `supabase-db` (ne jamais afficher les secrets).
