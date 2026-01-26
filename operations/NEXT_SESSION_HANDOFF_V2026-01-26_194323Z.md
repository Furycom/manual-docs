# NEXT SESSION HANDOFF — 2026-01-26 (AUTO)

Date (UTC): 2026-01-26T19:43:23Z
Repo: /home/furycom/manual-docs
Branch: main
HEAD (before write): 03ee358

## Objectif (prochaine session)
- Demarrer MCP-first (etat observe -> choisir UNE action suivante).
- Assurer que les canoniques LATEST sont coherents.

## MCP (collecte)
Base: http://192.168.2.230:4000

### MCP http/bytes (debug)
- health:     http=200 bytes=210
- metrics:    http=200 bytes=273
- issues:     http=200 bytes=3347
- last-seen:  http=200 bytes=3223
- docker-sum: http=200 bytes=1827

Health (raw, court):
{"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-26T19:43:24.078Z"}

### Issues ouvertes (resume)
counts: critical=2 warning=5
critical_list:
- CRITICAL SERVICE_MISSING: host=furycomai container=youthful_pike
- CRITICAL pool_status: pool=RZ1-5TB-4X code=FAILING_DEV
NEXTSTEP: priority TrueNAS pool DEGRADED (FAILING_DEV) -> diagnose disk / resilver / SMART on TrueNAS

### Issues preview (borne, 600 chars)
{"ok":true,"status":200,"data":[{"type":"SERVICE_MISSING","domain":"docker","scope1":"furycomai","scope2":"youthful_pike","scope3":null,"message":"Expected container youthful_pike on furycomai but it is not observed","payload":{"notes":"autodiscover","status":"missing_expected","hostname":"furycomai","enforce_after":null,"runtime_state":null,"container_name":"youthful_pike","expected_state":"running","lifecycle_state":"active","first_seen_required":true},"severity":"critical","computed_at":"2026-01-26T19:43:24.222468+00:00"},{"type":"pool_status","domain":"truenas","scope1":"truenas","scope2":

## Meilleure prochaine etape (heuristique)
priority TrueNAS pool DEGRADED (FAILING_DEV) -> diagnose disk / resilver / SMART on TrueNAS

## Sequence de demarrage (next session) — 1 bloc
Sur `furymcp` :
1) `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Reprendre ici avec la sortie, puis executer UNE action (selon "Meilleure prochaine etape").
