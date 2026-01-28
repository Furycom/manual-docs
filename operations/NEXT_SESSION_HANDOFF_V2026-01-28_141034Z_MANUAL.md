# NEXT SESSION HANDOFF — 2026-01-28 (MANUAL)

Date (UTC): 2026-01-28T14:10:34Z
Repo: /home/furycom/manual-docs
Branch: main

## Objectif (prochaine session)
- Démarrer MCP-first (état observé -> choisir UNE action suivante).
- Se concentrer uniquement sur BRUCE (docker expected/observed + collectors + MCP health).
- Ignorer les issues hors BRUCE pour cette session (TrueNAS deferred).

## MCP (collecte)
Base: http://192.168.2.230:4000
Health (dernier connu):
{"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-28T14:07:49.198Z"}

## Issues ouvertes (resume)
counts: critical=13 warning=5

critical_list (BRUCE/docker):
- SERVICE_MISSING: host=furyssh container=dozzle-agent
- SERVICE_MISSING: host=furyssh container=speaches
- SERVICE_MISSING: host=mcp-gateway containers: code-server, dashy, mcp-gateway, mcp-manual, mcp-shell, netdata, ntopng, portainer, termix, uptime-kuma

critical_list (deferred, hors BRUCE):
- TrueNAS pool_status: pool=RZ1-5TB-4X code=FAILING_DEV (DEGRADED)

## Issues preview (BRUCE-only, interpretation courte)
- Les “SERVICE_MISSING” sur hosts `mcp-gateway` et `furyssh` sont probablement des faux positifs:
  - `docker summary` et `last-seen` ne listent pas ces hostnames pour `source_id=docker`.
  - Donc soit (a) attendus hostnames incorrects, (b) hosts non collectés par le collector docker, (c) ancien naming.

## Meilleure prochaine etape (UNE action)
BRUCE-only: auditer/corriger `expected_docker_services` pour `hostname in ('mcp-gateway','furyssh')` afin d’éliminer les faux CRITICAL.

## Sequence de demarrage (next session) — 1 bloc
Sur `furymcp` :
1) `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Puis exécuter l’audit SQL (ci-dessous) et décider quoi corriger.

### Audit SQL (à exécuter sur supabase-db)
Objectif: comparer attendus vs hosts réellement observés (source_id=docker).

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 supabase 'docker exec -i supabase-db psql -U postgres -d postgres -X -q -P pager=off -c "
select hostname, container_name, expected_state, severity, lifecycle_state
from public.v_expected_docker_services_effective
where hostname in (''mcp-gateway'',''furyssh'')
order by hostname, container_name;
"'

ssh -o BatchMode=yes -o ConnectTimeout=5 supabase 'docker exec -i supabase-db psql -U postgres -d postgres -X -q -P pager=off -c "
select distinct hostname
from public.observed_snapshots
where source_id=''docker''
  and ts >= now() - interval ''2 hours''
order by hostname;
"'
````

