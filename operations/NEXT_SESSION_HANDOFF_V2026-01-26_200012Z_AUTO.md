# NEXT SESSION HANDOFF — 2026-01-26 (AUTO)

Date (UTC): 2026-01-26T20:00:12Z
Repo: /home/furycom/manual-docs
Branch: main
HEAD (before write): 0fa3db2

## Objectif (prochaine session)
- Démarrer MCP-first (état observé -> choisir UNE action suivante).
- Se concentrer uniquement sur BRUCE (docker expected/observed + collectors + MCP health).
- Ne pas traiter TrueNAS dans cette session (deferred).

## MCP (collecte)
Base: http://192.168.2.230:4000

### MCP http/bytes (debug)
- health:     http=200 bytes=210
- metrics:    http=200 bytes=273
- issues:     http=200 bytes=3347
- last-seen:  http=200 bytes=3223
- docker-sum: http=200 bytes=1827

Health (raw, court):
{"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-26T20:00:12.264Z"}

### Issues ouvertes (resume)


### Issues preview (borne, 600 chars)
{"ok":true,"status":200,"data":[{"type":"SERVICE_MISSING","domain":"docker","scope1":"furycomai","scope2":"youthful_pike","scope3":null,"message":"Expected container youthful_pike on furycomai but it is not observed","payload":{"notes":"autodiscover","status":"missing_expected","hostname":"furycomai","enforce_after":null,"runtime_state":null,"container_name":"youthful_pike","expected_state":"running","lifecycle_state":"active","first_seen_required":true},"severity":"critical","computed_at":"2026-01-26T20:00:12.389834+00:00"},{"type":"pool_status","domain":"truenas","scope1":"truenas","scope2":

## Meilleure prochaine etape (heuristique)
BRUCE-only: inspect docker expected/observed (no NEXTSTEP parsed)

## Sequence de demarrage (next session) — 1 bloc
Sur `furymcp` :
1) `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Reprendre ici avec la sortie, puis executer UNE action (selon "Meilleure prochaine etape").
