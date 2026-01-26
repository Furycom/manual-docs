# NEXT SESSION HANDOFF — 2026-01-26 (AUTO)

Date (UTC): 2026-01-26T18:04:44Z
Repo: /home/furycom/manual-docs
Branch: main
HEAD (before write): 15cde1f

## Objectif (prochaine session)
- Démarrer MCP-first (état observé -> choisir UNE action suivante).
- Assurer que les canoniques LATEST sont cohérents.

## MCP (collecte)
Base: http://192.168.2.230:4000

### MCP http/bytes (debug)
- health:     http=200 bytes=210
- metrics:    http=200 bytes=273
- issues:     http=200 bytes=3347
- last-seen:  http=200 bytes=3223
- docker-sum: http=200 bytes=1827

Health (raw, court):
{"status":"ok","supabase":{"configured":true,"url":"http://192.168.2.206:3000","status":"ok","error":null},"manual":{"root":"/manual-docs","accessible":true,"error":null},"timestamp":"2026-01-26T18:04:44.623Z"}

### Issues ouvertes (résumé)
counts: critical=2 warning=5
critical_list:
- CRITICAL SERVICE_MISSING: host=furycomai container=youthful_pike
- CRITICAL pool_status: pool=RZ1-5TB-4X code=FAILING_DEV

### Issues preview (borné, 40 lignes)
{"ok":true,"status":200,"data":[{"type":"SERVICE_MISSING","domain":"docker","scope1":"furycomai","scope2":"youthful_pike","scope3":null,"message":"Expected container youthful_pike on furycomai but it is not observed","payload":{"notes":"autodiscover","status":"missing_expected","hostname":"furycomai","enforce_after":null,"runtime_state":null,"container_name":"youthful_pike","expected_state":"running","lifecycle_state":"active","first_seen_required":true},"severity":"critical","computed_at":"2026-01-26T18:04:44.850231+00:00"},{"type":"pool_status","domain":"truenas","scope1":"truenas","scope2":"RZ1-5TB-4X","scope3":"FAILING_DEV","message":"TrueNAS pool \"RZ1-5TB-4X\" is DEGRADED (code=FAILING_DEV, healthy=false)","payload":{"status":"DEGRADED","healthy":false,"warning":false,"issue_key":"truenas|pool_status|RZ1-5TB-4X","pool_name":"RZ1-5TB-4X","free_bytes":1041123876864,"size_bytes":7988639170560,"scrub_state":"FINISHED","status_code":"FAILING_DEV","scrub_errors":0,"scrub_end_utc":null,"scrub_percent":2.517419494688511,"scrub_function":"RESILVER","allocated_bytes":6947515293696,"scrub_start_utc":null,"fragmentation_pct":31},"severity":"critical","computed_at":"2026-01-26T17:52:04.337354+00:00"},{"type":"service_status","domain":"truenas","scope1":"truenas","scope2":"glusterd","scope3":"STOPPED","message":"TrueNAS service \"glusterd\" is STOPPED","payload":{"raw":{"id":26,"pids":[],"state":"STOPPED","enable":false,"service":"glusterd"},"state":"STOPPED","enabled":false,"running":null,"issue_key":"truenas|service_status|glusterd","service_name":"glusterd"},"severity":"warning","computed_at":"2026-01-26T17:52:04.337354+00:00"},{"type":"service_status","domain":"truenas","scope1":"truenas","scope2":"iscsitarget","scope3":"STOPPED","message":"TrueNAS service \"iscsitarget\" is STOPPED","payload":{"raw":{"id":7,"pids":[],"state":"STOPPED","enable":false,"service":"iscsitarget"},"state":"STOPPED","enabled":false,"running":null,"issue_key":"truenas|service_status|iscsitarget","service_name":"iscsitarget"},"severity":"warning","computed_at":"2026-01-26T17:52:04.337354+00:00"},{"type":"service_status","domain":"truenas","scope1":"truenas","scope2":"nfs","scope3":"STOPPED","message":"TrueNAS service \"nfs\" is STOPPED","payload":{"raw":{"id":9,"pids":[],"state":"STOPPED","enable":false,"service":"nfs"},"state":"STOPPED","enabled":false,"running":null,"issue_key":"truenas|service_status|nfs","service_name":"nfs"},"severity":"warning","computed_at":"2026-01-26T17:52:04.337354+00:00"},{"type":"service_status","domain":"truenas","scope1":"truenas","scope2":"snmp","scope3":"STOPPED","message":"TrueNAS service \"snmp\" is STOPPED","payload":{"raw":{"id":10,"pids":[],"state":"STOPPED","enable":false,"service":"snmp"},"state":"STOPPED","enabled":false,"running":null,"issue_key":"truenas|service_status|snmp","service_name":"snmp"},"severity":"warning","computed_at":"2026-01-26T17:52:04.337354+00:00"},{"type":"service_status","domain":"truenas","scope1":"truenas","scope2":"ups","scope3":"STOPPED","message":"TrueNAS service \"ups\" is STOPPED","payload":{"raw":{"id":14,"pids":[],"state":"STOPPED","enable":false,"service":"ups"},"state":"STOPPED","enabled":false,"running":null,"issue_key":"truenas|service_status|ups","service_name":"ups"},"severity":"warning","computed_at":"2026-01-26T17:52:04.337354+00:00"}]}
## Meilleure prochaine étape (heuristique)
A) Priorité: TrueNAS pool DEGRADED (FAILING_DEV) -> diagnostiquer disque / état resilver / SMART (sur TrueNAS).

## Séquence de démarrage (next session) — 1 bloc
Sur `furymcp` :
1) `/home/furycom/bootstrap.sh | sed -n '1,220p'`
2) Reprendre ici avec la sortie, puis exécuter UNE action (selon "Meilleure prochaine étape").
