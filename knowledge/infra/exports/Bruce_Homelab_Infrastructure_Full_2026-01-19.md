# Bruce Homelab — Inventaire & Structure (MD)

**Généré le :** 2026-01-19T23:34:00Z

Ce document regroupe l’inventaire *le plus complet possible* à partir des exports et vérifications SSH partagés dans cette conversation.

> Sécurité : les secrets (mots de passe, tokens, clés) sont volontairement **redactés**.

## Sources de données utilisées

- Validation rapide (ping + endpoints clés) : 2026-01-19 (furymcp) — ajout embedder 192.168.2.85.

- Export NetBox : `netbox_asset_ips_latest` (58 lignes) — fourni en texte.

- Observation Proxmox : `bruce_observed_proxmox_vms_latest_v2` (14 lignes) — fourni en texte.

- Observation Docker : `observed_docker_containers_latest` (99 lignes) — fourni en texte.

- Backup Termix (SQLite) : `termix-export-Furycom-2026-01-11T15-25-37-550Z.sqlite`.

- Backup Uptime Kuma : `Uptime_Kuma_Backup_2026_01_11-10_23_52.json`.

- Vérifications SSH live : VM `minecraft` (Ubuntu) + hôte `furycomai` + hôte `truenas`.

## Vue logique (couches)

1) **Machines physiques** → 2) **Hyperviseurs/Virtualisation** (Proxmox + TrueNAS VMs) → 3) **VMs** → 4) **Docker/Services** → 5) **Endpoints/Monitoring**.

## 1) Machines physiques (couche matérielle)

### Noyau (serveurs / infra)

- **Routeur / passerelle LAN** : `mynetwork.home` — `192.168.2.1`

- **Proxmox Box 1 (cluster Proxmoxbox1)** : `Promox-Box` — IP **confirmée** `192.168.2.58`

- **Proxmox Box 2 (cluster Proxmoxbox2)** : `pve` — IP **confirmée** `192.168.2.103`

- **TrueNAS SCALE** : `truenas` — `192.168.2.183`

- **Serveur GPU / IA** : `FurycomAI` / hostname `furycomai` — `192.168.2.32`

- **Poste Windows** : `WIN-SKKNGPMS1C5` — `192.168.2.190` (Docker présent via host `furyssh`)


### Périphériques (selon NetBox)

Inclut des entrées de type `lan-ip-*`, caméras Reolink, imprimante, etc. (voir inventaire NetBox complet plus bas).

## 2) Virtualisation

### 2.1 Proxmoxbox1 — nœud `Promox-Box` (192.168.2.58)

- VM100 : **supabase-vm** — `192.168.2.206` — Docker : stack Supabase + scripts BRUCE.

- VM102 : **homeassistant** — `192.168.2.248`.

- VM103 : **mcp-gateway** — `192.168.2.230` (alias aussi vu : `192.168.2.238`).

- VM111 : **ROTKI** — `192.168.2.231`.


### 2.2 Proxmoxbox2 — nœud `pve` (192.168.2.103)

- VM201 : **box2-edge** — `192.168.2.87`.

- VM202 : **box2-secrets** — `192.168.2.249`.

- VM203 : **box2-automation** — `192.168.2.174`.

- VM204 : **box2-observability** — `192.168.2.154`.

- VM205 : **box2-docs** — `192.168.2.113`.

- VM206 : **box2-media** — `192.168.2.123` (containers volontairement non démarrés, selon notes).

- VM207 : **box2-tube** — `192.168.2.173`.

- VM208 : **box2-daily** — `192.168.2.12`.

- VM9000 : **box2-ubuntu2404-template** — template (stopped / inutilisé).


### 2.3 TrueNAS — Virtual Machines

- VM : **Minecraft** — état RUNNING, autostart activé (interface TrueNAS). IP de la VM : `192.168.2.177`.

  - NIC : virtio, attachée à `eno1` (TrueNAS).

  - ZVOL : `/dev/zvol/RZ1-5TB-4X/minecraft/Minecraft-mai5pi`.

## 3) Docker & services (par hôte)

### 3.1 FurycomAI (192.168.2.32) — Docker direct (pas une VM)

- `openwebui` — port `3000/tcp` (LAN)

- `ollama` — port `11434/tcp` (LAN)

- `cloudflared` — tunnel Cloudflare **pour l’IA** (selon toi : un des 2 tunnels)

- `dozzle-agent` — `7007/tcp`




### 3.1.1 Embedder (192.168.2.85) — service embeddings dédié

- Base URL : `http://192.168.2.85:8081`
- Endpoints : `GET /health`, `POST /embed`, `GET /openapi.json`
- Health (observé 2026-01-19) : `ok=true`, `model=BAAI/bge-m3`, `device=cuda`, `fp16=true`, `normalize=true`, `dims_expected=1024`


### 3.2 Proxmoxbox1 / VM103 (192.168.2.230) — *alias de hostname* `mcp-gateway` et `furymcp`

Tu as confirmé que `mcp-gateway` et `furymcp` représentent **la même machine** (2 noms).

- Services Docker observés (ensemble) : `dashy`, `mcp-gateway`, `mcp-shell`, `mcp-manual`, `code-server`, `netdata`, `portainer`, `termix`, `uptime-kuma`, `ntopng`.


### 3.3 Proxmoxbox1 / VM100 Supabase (192.168.2.206)

- Stack **Supabase auto-hébergée** : `supabase-db`, `supabase-kong`, `supabase-auth`, `supabase-rest`, `supabase-studio`, `supabase-storage`, `supabase-pooler`, etc.

- `supabase-db-forward` (socat) exposé sur `54322->5432`.

- `dozzle-agent`.


### 3.4 Proxmoxbox1 / VM111 ROTKI (192.168.2.231)

- `rotki` — `8085/tcp`

- `linkwarden-db` (Postgres), `linkwarden-meilisearch`.

- `dozzle`, `dozzle-agent`.


### 3.5 Proxmoxbox2 / VM201 box2-edge (192.168.2.87)

- Reverse-proxy + SSO : `nginx-proxy-manager` (80/81/443), `authentik-server` (8061), DBs/Redis.

- `dozzle-agent`.


### 3.6 Proxmoxbox2 / VM202 box2-secrets (192.168.2.249)

- Coffres-forts : `vaultwarden` (8080 + 3012), `backvault` (8212).

- `dozzle-agent`.


### 3.7 Proxmoxbox2 / VM203 box2-automation (192.168.2.174)

- `n8n` (5678), `ntfy` (8080), `changedetection` (5000), `playwright-chrome` (3000), `duplicati` (8201), `prunemate` (8211), `mcp-inspector` (8213), `diun`, `netalertx`, `dozzle-agent`.


### 3.8 Proxmoxbox2 / VM204 box2-observability (192.168.2.154)

- `grafana` (3001), `prometheus` (9090), `alertmanager` (9093), `loki` (3100), `otel-collector` (4317-4318, 13133), `vector` (8686), `dozzle-agent`.


### 3.9 Proxmoxbox2 / VM205 box2-docs (192.168.2.113)

- `bookstack` (8014), `paperless-web` (8015), `stirling-pdf` (8016), `netbox` (8043), DBs/Redis, `dozzle-agent`.


### 3.10 Proxmoxbox2 / VM208 box2-daily (192.168.2.12)

- `freshrss` (8021), `readeck` (8022), `maloja` (8023), `snappymail` (8024), `multi-scrobbler` (8025), `tandoor-web` (8026), DB, `dozzle-agent`.


### 3.11 Proxmoxbox2 / VM207 box2-tube (192.168.2.173)

- `tubearchivist` (8041), `tubearchivist-es` (internal 9200/9300), `tubearchivist-redis`, `dozzle-agent`.


### 3.12 Proxmoxbox2 / VM206 box2-media (192.168.2.123)

- `dozzle-agent` seulement (selon l’export Docker) — services médias planifiés mais stoppés volontairement.


### 3.13 Windows workstation (192.168.2.190) — host Docker `furyssh`

- `speaches` (CUDA) — `8000/tcp`

- `dozzle-agent` — `7007/tcp`


### 3.14 TrueNAS Apps (k3s)

- Release ACTIVE : `qbittorrent`.


### 3.15 TrueNAS VM Minecraft (192.168.2.177)

- Ubuntu 24.04.3 LTS.

- Docker actif + `wings.service` (Pelican Wings Daemon) actif.

- Containers (observés en live) :

  - `pelican-panel` — `ghcr.io/pelican-dev/panel:latest` — ports: 0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp — Panel (web)

  - `pelican-postgres` — `postgres:16-alpine` — ports: 5432/tcp — DB for panel

  - `pelican-redis` — `redis:7-alpine` — ports: 6379/tcp — Redis for panel

  - `dozzle-agent` — `amir20/dozzle:latest` — ports: 0.0.0.0:7007->7007/tcp — Logs agent

  - `minecraft-server-container` — `ghcr.io/parkervcp/yolks:java_21` — ports: 192.168.2.177:25565->25565/tcp+udp — Minecraft server (Wings-managed)

- Ports à l’écoute (extrait) : 80, 443, 22, 25565, 7007, 8080, 2022.

- `cloudflared` binaire présent (`/usr/local/bin/cloudflared`) **mais aucun service systemd / config de tunnel trouvé** (à confirmer : possiblement installé mais inutilisé).

## 4) Exposition Internet / DNS / Cloudflare

- **minecraft.furycom.com** : en DNS, l’enregistrement **A** pointe vers l’IP WAN `142.122.13.86` (dig depuis la VM Minecraft).

- Hypothèse actuelle (la plus probable selon tes tests) : **NAT/port-forward au routeur** → `TCP/UDP 25565` vers `192.168.2.177` (VM Minecraft).

- Tunnels Cloudflare :

  - Tunnel **IA/OpenWebUI** : via container `cloudflared` sur `furycomai` (confirmé par `docker ps`).

  - Tunnel Minecraft : **non confirmé** (cloudflared non vu côté TrueNAS; binaire présent côté VM Minecraft mais sans config détectée).

## 5) Monitoring & outils d’exploitation

### 5.1 Uptime Kuma — hiérarchie (backup)

- CloudFlared (group, id=24)

  - FurycomAI Cloudflared (id=14) — http — https://ai.furycom.com

  - Minecraft cloudflared (id=15) — port — minecraft.furycom.com:25565

- Docker on FurycomAI (group, id=27)

  - Ollama – furycomai (id=12) — http — http://192.168.2.32:11434/api/tags

  - OpenWebUI – furycomai (id=13) — http — http://192.168.2.32:3000/

- Docker on MCP VME (group, id=25)

  - Dashy (id=4) — http — http://192.168.2.230:9090

  - NetData (id=5) — http — http://192.168.2.230:19999

  - Portainer (id=6) — http — https://192.168.2.230:9443

  - Termix (id=34) — http — http://192.168.2.230:18080/

  - mcp code-server (id=20) — http — http://192.168.2.230:8080

  - mcp-gateway (id=19) — http — http://192.168.2.230:4000/health

  - mcp-manual (id=17) — http — http://192.168.2.230:8181

  - mcp-shell (id=21) — http — http://192.168.2.230:7681

  - ntopng (id=16) — http — http://192.168.2.238:3000

  - uptime-kuma (id=18) — http — http://192.168.2.230:3001

- Proxmox Machine (group, id=26)

  - HomeAssistant (id=30) — http — http://192.168.2.248:8123

  - Rotki (id=8) — http — http://192.168.2.231:8085

  - Supabase (id=29) — ping — 192.168.2.206

- Real Computers (group, id=23)

  - Truenas (id=2) — http — https://192.168.2.183

  - Furycom PC (id=10) — ping — 192.168.2.190

  - FurycomAI (computer) (id=11) — ping — 192.168.2.32

  - Proxmox (id=1) — ping — 192.168.2.230

  - Proxmox2 (id=40) — ping — 192.168.2.103

- Reolink (group, id=39)

  - Reolink 180 (id=38) — ping — 192.168.2.74

  - Reolink Doorbell1 (id=37) — ping — 192.168.2.237

  - Reolink Mayvee (id=36) — ping — 192.168.2.218

  - reolink doorbell2 (id=35) — ping — 192.168.2.205

- Truenas VM (group, id=32)

  - Qbitorrent (id=31) — http — http://192.168.2.183:30024

  - Pellican Minecraft Server (id=33) — ping — 192.168.2.177

- docker on FurycomPC (group, id=28)

  - WhisperV3 (id=9) — http — http://192.168.2.190:8000/v1/audio/transcriptions


### 5.2 Uptime Kuma — liste des monitors (table)

|   id | name                      | type   | hostname                                          | url                                | port   | parent   | pathName                                    | active   |   interval |
|-----:|:--------------------------|:-------|:--------------------------------------------------|:-----------------------------------|:-------|:---------|:--------------------------------------------|:---------|-----------:|
|   24 | CloudFlared               | group  |                                                   | https://                           |        |          | CloudFlared                                 | True     |         60 |
|   27 | Docker on FurycomAI       | group  |                                                   | https://                           |        |          | Docker on FurycomAI                         | True     |         60 |
|   25 | Docker on MCP VME         | group  |                                                   | https://                           |        |          | Docker on MCP VME                           | True     |         60 |
|   26 | Proxmox Machine           | group  |                                                   | https://                           |        |          | Proxmox Machine                             | True     |         60 |
|   23 | Real Computers            | group  |                                                   | https://                           |        |          | Real Computers                              | True     |         60 |
|   39 | Reolink                   | group  |                                                   | https://                           |        |          | Reolink                                     | True     |         60 |
|   32 | Truenas VM                | group  |                                                   | https://                           |        |          | Truenas VM                                  | True     |         60 |
|   28 | docker on FurycomPC       | group  |                                                   | https://                           |        |          | docker on FurycomPC                         | True     |         60 |
|    4 | Dashy                     | http   |                                                   | http://192.168.2.230:9090          |        | 25.0     | Docker on MCP VME / Dashy                   | True     |         60 |
|   14 | FurycomAI Cloudflared     | http   |                                                   | https://ai.furycom.com             |        | 24.0     | CloudFlared / FurycomAI Cloudflared         | True     |         60 |
|   30 | HomeAssistant             | http   |                                                   | http://192.168.2.248:8123          |        | 26.0     | Proxmox Machine / HomeAssistant             | True     |         60 |
|    5 | NetData                   | http   |                                                   | http://192.168.2.230:19999         |        | 25.0     | Docker on MCP VME / NetData                 | True     |         60 |
|   12 | Ollama – furycomai        | http   |                                                   | http://192.168.2.32:11434/api/tags |        | 27.0     | Docker on FurycomAI / Ollama – furycomai    | True     |         60 |
|   13 | OpenWebUI – furycomai     | http   |                                                   | http://192.168.2.32:3000/          |        | 27.0     | Docker on FurycomAI / OpenWebUI – furycomai | True     |         60 |
|    6 | Portainer                 | http   |                                                   | https://192.168.2.230:9443         |        | 25.0     | Docker on MCP VME / Portainer               | True     |         60 |
|   31 | Qbitorrent                | http   |                                                   | http://192.168.2.183:30024         |        | 32.0     | Truenas VM / Qbitorrent                     | True     |         60 |
|    8 | Rotki                     | http   |                                                   | http://192.168.2.231:8085          |        | 26.0     | Proxmox Machine / Rotki                     | True     |         60 |
|   34 | Termix                    | http   |                                                   | http://192.168.2.230:18080/        |        | 25.0     | Docker on MCP VME / Termix                  | True     |         60 |
|    2 | Truenas                   | http   |                                                   | https://192.168.2.183              |        | 23.0     | Real Computers / Truenas                    | True     |         60 |
|    9 | WhisperV3                 | http   | http://192.168.2.190:8000/v1/audio/transcriptions | http://192.168.2.190:8000/health   |        | 28.0     | docker on FurycomPC / WhisperV3             | True     |         60 |
|   20 | mcp code-server           | http   |                                                   | http://192.168.2.230:8080          |        | 25.0     | Docker on MCP VME / mcp code-server         | True     |         60 |
|   19 | mcp-gateway               | http   |                                                   | http://192.168.2.230:4000/health   |        | 25.0     | Docker on MCP VME / mcp-gateway             | True     |         60 |
|   17 | mcp-manual                | http   |                                                   | http://192.168.2.230:8181          |        | 25.0     | Docker on MCP VME / mcp-manual              | True     |         60 |
|   21 | mcp-shell                 | http   |                                                   | http://192.168.2.230:7681          |        | 25.0     | Docker on MCP VME / mcp-shell               | True     |         60 |
|   16 | ntopng                    | http   |                                                   | http://192.168.2.238:3000          |        | 25.0     | Docker on MCP VME / ntopng                  | True     |         60 |
|   18 | uptime-kuma               | http   |                                                   | http://192.168.2.230:3001          |        | 25.0     | Docker on MCP VME / uptime-kuma             | True     |         60 |
|   10 | Furycom PC                | ping   | 192.168.2.190                                     | https://                           |        | 23.0     | Real Computers / Furycom PC                 | True     |         60 |
|   11 | FurycomAI (computer)      | ping   | 192.168.2.32                                      | https://                           |        | 23.0     | Real Computers / FurycomAI (computer)       | True     |         60 |
|   33 | Pellican Minecraft Server | ping   | 192.168.2.177                                     | 192.168.2.177                      |        | 32.0     | Truenas VM / Pellican Minecraft Server      | True     |         60 |
|    1 | Proxmox                   | ping   | 192.168.2.230                                     | https://192.168.2.230              |        | 23.0     | Real Computers / Proxmox                    | True     |         60 |
|   40 | Proxmox2                  | ping   | 192.168.2.103                                     | https://192.168.2.230              |        | 23.0     | Real Computers / Proxmox2                   | True     |         60 |
|   38 | Reolink 180               | ping   | 192.168.2.74                                      | https://                           |        | 39.0     | Reolink / Reolink 180                       | True     |         60 |
|   37 | Reolink Doorbell1         | ping   | 192.168.2.237                                     | https://                           |        | 39.0     | Reolink / Reolink Doorbell1                 | True     |         60 |
|   36 | Reolink Mayvee            | ping   | 192.168.2.218                                     | https://                           |        | 39.0     | Reolink / Reolink Mayvee                    | True     |         60 |
|   29 | Supabase                  | ping   | 192.168.2.206                                     | http://192.168.2.206               |        | 26.0     | Proxmox Machine / Supabase                  | True     |         60 |
|   35 | reolink doorbell2         | ping   | 192.168.2.205                                     | https://                           |        | 39.0     | Reolink / reolink doorbell2                 | True     |         60 |
|   15 | Minecraft cloudflared     | port   | minecraft.furycom.com                             | minecraft.furycom.com              | 25565  | 24.0     | CloudFlared / Minecraft cloudflared         | True     |         60 |


### 5.3 Termix — inventaire SSH (backup)

Cette liste décrit **tes cibles SSH** (noms, IPs, dossiers). Elle est utile pour recroiser les noms/aliases.

| folder         | name                      | ip            |   port | username   | auth_type   | default_path   | updated_at          |
|:---------------|:--------------------------|:--------------|-------:|:-----------|:------------|:---------------|:--------------------|
| IOT            | RaspberryPi4              | 192.168.2.86  |     22 | osmc       | password    | /              | 2025-12-03 20:43:00 |
| Proxbox2-PVE   | 201 — box2-edge           | 192.168.2.87  |     22 | yann       | credential  | /              | 2025-12-26 14:39:36 |
| Proxbox2-PVE   | 202 — box2-secrets        | 192.168.2.249 |     22 | yann       | credential  | /              | 2025-12-26 14:40:08 |
| Proxbox2-PVE   | 203 — box2-automation     | 192.168.2.174 |     22 | yann       | credential  | /              | 2025-12-26 14:41:25 |
| Proxbox2-PVE   | 204 — box2-observability  | 192.168.2.154 |     22 | yann       | credential  | /              | 2025-12-26 14:41:53 |
| Proxbox2-PVE   | 205 — box2-docs           | 192.168.2.113 |     22 | yann       | credential  | /              | 2025-12-26 00:30:05 |
| Proxbox2-PVE   | 206 — box2-media          | 192.168.2.123 |     22 | yann       | credential  | /              | 2025-12-26 14:42:30 |
| Proxbox2-PVE   | 207 — box2-tube           | 192.168.2.173 |     22 | yann       | credential  | /              | 2025-12-26 14:42:56 |
| Proxbox2-PVE   | 208 — box2-daily          | 192.168.2.12  |     22 | yann       | credential  | /              | 2025-12-26 14:23:33 |
| RealComputers  | FurycomAI                 | 192.168.2.32  |     22 | furycom    | password    | /              | 2025-12-01 23:38:07 |
| RealComputers  | Proxmox machine           | 192.168.2.58  |     22 | root       | password    | /              | 2025-12-02 02:36:29 |
| RealComputers  | Proxmox machine2          | 192.168.2.103 |     22 | root       | password    | /              | 2025-12-20 19:14:06 |
| RealComputers  | TrueNAS                   | 192.168.2.183 |     22 | root       | password    | /              | 2025-12-01 23:32:53 |
| RealComputers  | furyssh                   | 192.168.2.190 |     22 | furyssh    | password    | /              | 2025-12-02 02:09:22 |
| VMS on Proxmox | MCP - VM Docker           | 192.168.2.230 |     22 | furycom    | password    | /              | 2025-12-01 22:36:49 |
| VMS on Proxmox | Rotki                     | 192.168.2.231 |     22 | furycom    | password    | /              | 2025-12-01 23:36:57 |
| VMS on Proxmox | Supabase                  | 192.168.2.206 |     22 | furycom    | password    | /              | 2025-12-01 23:38:43 |
| Vms on Furyai  | Pellican Minecraft Server | 192.168.2.177 |     22 | furycom    | password    | /              | 2025-12-01 23:42:59 |


## 6) Inventaires bruts (verbatim)

### 6.1 NetBox — `netbox_asset_ips_latest` (58 lignes)

```csv
asset_type,asset_name,role,device_model,primary_ip,ips,site,cluster,status
device,34:e1:d1:82:06:c7,LAN Device,Generic LAN device,192.168.2.90,192.168.2.90,Bruce,"",active
device,box2-automation,Server,Generic x86_64,"","",Bruce,"",active
device,box2-daily,Server,Generic x86_64,"","",Bruce,"",active
device,box2-docs,Server,Generic x86_64,"","",Bruce,"",active
device,box2-edge,Server,Generic x86_64,"","",Bruce,"",active
device,box2-media,Server,Generic x86_64,"","",Bruce,"",active
device,box2-observability,Server,Generic x86_64,"","",Bruce,"",active
device,box2-secrets,Server,Generic x86_64,"","",Bruce,"",active
device,box2-tube,Server,Generic x86_64,"","",Bruce,"",active
device,FurycomAI,AI Server,GPU Ubuntu Host,192.168.2.32,192.168.2.32,Bruce,"",active
device,lan-ip-192-168-2-130,LAN Device,Generic LAN device,192.168.2.130,192.168.2.130,Bruce,"",active
device,lan-ip-192-168-2-142,LAN Device,Generic LAN device,192.168.2.142,192.168.2.142,Bruce,"",active
device,lan-ip-192-168-2-191,LAN Device,Generic LAN device,192.168.2.191,192.168.2.191,Bruce,"",active
device,lan-ip-192-168-2-207,LAN Device,Generic LAN device,192.168.2.207,192.168.2.207,Bruce,"",active
device,lan-ip-192-168-2-209,LAN Device,Generic LAN device,192.168.2.209,192.168.2.209,Bruce,"",active
device,lan-ip-192-168-2-21,LAN Device,Generic LAN device,192.168.2.21,192.168.2.21,Bruce,"",active
device,lan-ip-192-168-2-210,LAN Device,Generic LAN device,192.168.2.210,192.168.2.210,Bruce,"",active
device,lan-ip-192-168-2-218,LAN Device,Generic LAN device,192.168.2.218,192.168.2.218,Bruce,"",active
device,lan-ip-192-168-2-22,LAN Device,Generic LAN device,192.168.2.22,192.168.2.22,Bruce,"",active
device,lan-ip-192-168-2-239,LAN Device,Generic LAN device,192.168.2.239,192.168.2.239,Bruce,"",active
device,lan-ip-192-168-2-240,LAN Device,Generic LAN device,192.168.2.240,192.168.2.240,Bruce,"",active
device,lan-ip-192-168-2-242,LAN Device,Generic LAN device,192.168.2.242,192.168.2.242,Bruce,"",active
device,lan-ip-192-168-2-30,LAN Device,Generic LAN device,192.168.2.30,192.168.2.30,Bruce,"",active
device,lan-ip-192-168-2-39,LAN Device,Generic LAN device,192.168.2.39,192.168.2.39,Bruce,"",active
device,lan-ip-192-168-2-41,LAN Device,Generic LAN device,192.168.2.41,192.168.2.41,Bruce,"",active
device,lan-ip-192-168-2-46,LAN Device,Generic LAN device,192.168.2.46,192.168.2.46,Bruce,"",active
device,lan-ip-192-168-2-58,LAN Device,Generic LAN device,192.168.2.58,192.168.2.58,Bruce,"",active
device,lan-ip-192-168-2-64,LAN Device,Generic LAN device,192.168.2.64,192.168.2.64,Bruce,"",active
device,lan-mac-18-60-24-94-e2-d4,LAN Device,Generic LAN device,192.168.2.103,192.168.2.103,Bruce,"",active
device,lan-mac-56-2d-d1-4f-7b-a6,LAN Device,Generic LAN device,192.168.2.146,192.168.2.146 192.168.2.84,Bruce,"",active
device,lan-mac-b6-4a-a2-aa-32-dd,LAN Device,Generic LAN device,192.168.2.110,192.168.2.110,Bruce,"",active
device,minecraft,Server,Generic x86_64,192.168.2.177,192.168.2.177,Bruce,"",active
device,mynetwork.home,LAN Device,Generic LAN device,192.168.2.1,192.168.2.1,Bruce,"",active
device,nginx-192-168-2-50,LAN Device,Generic LAN device,192.168.2.50,192.168.2.50,Bruce,"",active
device,nginx-192-168-2-52,LAN Device,Generic LAN device,192.168.2.52,192.168.2.52,Bruce,"",active
device,osmc,LAN Device,Generic LAN device,192.168.2.86,192.168.2.86,Bruce,"",active
device,printer-brother-hl-l3290cdw-series,LAN Device,Brother HL-L3290CDW,192.168.2.16,192.168.2.16,Bruce,"",active
device,Promox-Box,hypervisor,Proxmox Host,"","",Bruce,Proxmoxbox1,active
device,pve,hypervisor,Proxmox Host,"","",Bruce,Proxmoxbox2,active
device,reolink-192-168-2-205,LAN Device,Reolink IP Camera,192.168.2.205,192.168.2.205,Bruce,"",active
device,reolink-192-168-2-237,LAN Device,Reolink IP Camera,192.168.2.237,192.168.2.237,Bruce,"",active
device,reolink-192-168-2-74,LAN Device,Reolink IP Camera,192.168.2.74,192.168.2.74,Bruce,"",active
device,truenas,NAS,TrueNAS SCALE Host,192.168.2.183,192.168.2.183,Bruce,"",active
device,WIN-SKKNGPMS1C5,Windows Host,Windows Workstation,192.168.2.190,192.168.2.190,Bruce,"",active
vm,box2-automation,"","",192.168.2.174,192.168.2.174,"",Proxmoxbox2,active
vm,box2-daily,"","",192.168.2.12,192.168.2.12,"",Proxmoxbox2,active
vm,box2-docs,"","",192.168.2.113,192.168.2.113,"",Proxmoxbox2,active
vm,box2-edge,"","",192.168.2.87,192.168.2.87,"",Proxmoxbox2,active
vm,box2-media,"","",192.168.2.123,192.168.2.123,"",Proxmoxbox2,active
vm,box2-observability,"","",192.168.2.154,192.168.2.154,"",Proxmoxbox2,active
vm,box2-secrets,"","",192.168.2.249,192.168.2.249,"",Proxmoxbox2,active
vm,box2-tube,"","",192.168.2.173,192.168.2.173,"",Proxmoxbox2,active
vm,box2-ubuntu2404-template,"","","","","",Proxmoxbox2,active
vm,homeassistant,"","",192.168.2.248,192.168.2.248,"",Proxmoxbox1,active
vm,mcp-gateway,"","",192.168.2.230,192.168.2.230 192.168.2.238,"",Proxmoxbox1,active
vm,ROTKI,"","",192.168.2.231,192.168.2.231,"",Proxmoxbox1,active
vm,supabase-vm,"","",192.168.2.206,192.168.2.206,"",Proxmoxbox1,active
```

### 6.2 Docker — `observed_docker_containers_latest` (99 lignes)

```csv
hostname,container_name,state,ports,image
box2-automation,changedetection,Up 9 days,"0.0.0.0:5000->5000/tcp, [::]:5000->5000/tcp",dgtlmoon/changedetection.io:latest
box2-automation,diun,Up 9 days,"",crazymax/diun:latest
box2-automation,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-automation,duplicati,Up 8 days,"0.0.0.0:8201->8200/tcp, [::]:8201->8200/tcp",lscr.io/linuxserver/duplicati:latest
box2-automation,mcp-inspector,Up 8 days,"6274/tcp, 6277/tcp, 0.0.0.0:8213->5173/tcp, [::]:8213->5173/tcp",ghcr.io/modelcontextprotocol/inspector:latest
box2-automation,n8n,Up 3 days,"0.0.0.0:5678->5678/tcp, [::]:5678->5678/tcp",n8nio/n8n:latest
box2-automation,n8n-postgres,Up 9 days,5432/tcp,postgres:16
box2-automation,netalertx,Up 9 days (healthy),"",ghcr.io/jokob-sk/netalertx:latest
box2-automation,ntfy,Up 3 days,"0.0.0.0:8080->80/tcp, [::]:8080->80/tcp",binwiederhier/ntfy:latest
box2-automation,playwright-chrome,Up 9 days,"0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp",browserless/chrome:latest
box2-automation,prunemate,Up 8 days,"0.0.0.0:8211->8080/tcp, [::]:8211->8080/tcp",docker.io/anoniemerd/prunemate:latest
box2-daily,dozzle-agent,Up 17 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-daily,freshrss,Up 9 days,"443/tcp, 0.0.0.0:8021->80/tcp, [::]:8021->80/tcp",lscr.io/linuxserver/freshrss:latest
box2-daily,maloja,Up 9 days,"0.0.0.0:8023->42010/tcp, [::]:8023->42010/tcp",krateng/maloja:latest
box2-daily,multi-scrobbler,Up 9 days,"0.0.0.0:8025->9078/tcp, [::]:8025->9078/tcp",foxxmd/multi-scrobbler:latest
box2-daily,readeck,Up 9 days,"0.0.0.0:8022->8000/tcp, [::]:8022->8000/tcp",codeberg.org/readeck/readeck:latest
box2-daily,snappymail,Up 9 days,"9000/tcp, 0.0.0.0:8024->8888/tcp, [::]:8024->8888/tcp",djmaze/snappymail:latest
box2-daily,tandoor-db,Up 9 days,5432/tcp,postgres:16-alpine
box2-daily,tandoor-web,Up 9 days,"8080/tcp, 0.0.0.0:8026->80/tcp, [::]:8026->80/tcp",vabene1111/recipes:latest
box2-docs,bookstack,Up 9 days,"443/tcp, 0.0.0.0:8014->80/tcp, [::]:8014->80/tcp",lscr.io/linuxserver/bookstack:latest
box2-docs,bookstack-db,Up 9 days,3306/tcp,mariadb:11
box2-docs,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-docs,netbox,Up 8 days,"0.0.0.0:8043->8080/tcp, [::]:8043->8080/tcp",netboxcommunity/netbox:latest
box2-docs,netbox-postgres,Up 8 days (healthy),5432/tcp,postgres:16-alpine
box2-docs,netbox-redis,Up 8 days,6379/tcp,redis:7-alpine
box2-docs,netbox-redis-cache,Up 8 days,6379/tcp,redis:7-alpine
box2-docs,paperless-db,Up 9 days,5432/tcp,postgres:16
box2-docs,paperless-redis,Up 9 days,6379/tcp,redis:7
box2-docs,paperless-web,Up 9 days (healthy),"0.0.0.0:8015->8000/tcp, [::]:8015->8000/tcp",ghcr.io/paperless-ngx/paperless-ngx:latest
box2-docs,stirling-pdf,Up 9 days,"0.0.0.0:8016->8080/tcp, [::]:8016->8080/tcp",frooodle/s-pdf:latest
box2-edge,authentik-postgresql,Up 8 days (healthy),5432/tcp,docker.io/library/postgres:16-alpine
box2-edge,authentik-redis,Up 8 days (healthy),6379/tcp,docker.io/library/redis:alpine
box2-edge,authentik-server,Up 8 days (healthy),"0.0.0.0:8061->9000/tcp, [::]:8061->9000/tcp",ghcr.io/goauthentik/server:2025.4.4
box2-edge,authentik-worker,Up 8 days (healthy),"",ghcr.io/goauthentik/server:2025.4.4
box2-edge,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-edge,nginx-proxy-manager,Up 9 days,"0.0.0.0:80-81->80-81/tcp, [::]:80-81->80-81/tcp, 0.0.0.0:443->443/tcp, [::]:443->443/tcp",jc21/nginx-proxy-manager:latest
box2-edge,npm-db,Up 9 days,3306/tcp,jc21/mariadb-aria:latest
box2-media,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-observability,alertmanager,Up 9 days,"0.0.0.0:9093->9093/tcp, [::]:9093->9093/tcp",prom/alertmanager:v0.27.0
box2-observability,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-observability,grafana,Up 9 days,"3000/tcp, 0.0.0.0:3001->3001/tcp, [::]:3001->3001/tcp",grafana/grafana:11.3.0
box2-observability,loki,Up 9 days,"0.0.0.0:3100->3100/tcp, [::]:3100->3100/tcp",grafana/loki:3.2.0
box2-observability,otel-collector,Up 9 days,"0.0.0.0:4317-4318->4317-4318/tcp, [::]:4317-4318->4317-4318/tcp, 0.0.0.0:13133->13133/tcp, [::]:13133->13133/tcp, 55678-55679/tcp",otel/opentelemetry-collector-contrib:0.113.0
box2-observability,prometheus,Up 9 days,"0.0.0.0:9090->9090/tcp, [::]:9090->9090/tcp",prom/prometheus:v2.54.1
box2-observability,vector,Up 9 days,"0.0.0.0:8686->8686/tcp, [::]:8686->8686/tcp",timberio/vector:0.40.1-alpine
box2-secrets,backvault,Up 8 days,"0.0.0.0:8212->8080/tcp, [::]:8212->8080/tcp",mvflc/backvault:latest
box2-secrets,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-secrets,vaultwarden,Up 9 days (healthy),"0.0.0.0:3012->3012/tcp, [::]:3012->3012/tcp, 0.0.0.0:8080->80/tcp, [::]:8080->80/tcp",vaultwarden/server:latest
box2-tube,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
box2-tube,tubearchivist,Up 45 seconds,"0.0.0.0:8041->8000/tcp, [::]:8041->8000/tcp",docker.io/bbilly1/tubearchivist:v0.5.8
box2-tube,tubearchivist-es,Up 8 days (healthy),"9200/tcp, 9300/tcp",docker.io/library/elasticsearch:8.12.2
box2-tube,tubearchivist-redis,Up 8 days,6379/tcp,docker.io/library/redis:7
furycomai,cloudflared,Up 8 days,"",cloudflare/cloudflared:2025.11.1
furycomai,dozzle-agent,Up 8 days,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
furycomai,ollama,Up 8 days (healthy),"0.0.0.0:11434->11434/tcp, [::]:11434->11434/tcp",sha256:d353379de60a961f877525bcb2f341a17bce1963322339420b369ed14f9c5605
furycomai,openwebui,Up 8 days (healthy),"0.0.0.0:3000->8080/tcp, [::]:3000->8080/tcp",ghcr.io/open-webui/open-webui:v0.6.36
furymcp,code-server,Up 9 days,"0.0.0.0:8080->8443/tcp, [::]:8080->8443/tcp",lscr.io/linuxserver/code-server:latest
furymcp,dozzle-agent,Up 18 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
furymcp,mcp-gateway,Up 9 days,"0.0.0.0:4000->4000/tcp, [::]:4000->4000/tcp",mcp-stack-mcp-gateway
furymcp,mcp-manual,Up 14 hours,"0.0.0.0:8181->8000/tcp, [::]:8181->8000/tcp",squidfunk/mkdocs-material
furymcp,mcp-shell,Up 9 days,"0.0.0.0:7681->7681/tcp, [::]:7681->7681/tcp",tsl0922/ttyd:latest
furymcp,netdata,Up 9 days (healthy),"0.0.0.0:19999->19999/tcp, [::]:19999->19999/tcp",netdata/netdata
furymcp,ntopng,Up 9 days,"",ntop/ntopng:latest
furymcp,portainer,Up 9 days,"8000/tcp, 9000/tcp, 0.0.0.0:9443->9443/tcp, [::]:9443->9443/tcp",portainer/portainer-ce:latest
furymcp,termix,Up 9 days,"30001-30006/tcp, 0.0.0.0:18080->8080/tcp, [::]:18080->8080/tcp",ghcr.io/lukegus/termix:latest
furymcp,uptime-kuma,Up 9 days (healthy),"0.0.0.0:3001->3001/tcp, [::]:3001->3001/tcp",louislam/uptime-kuma:1
furyssh,dozzle-agent,Up 36 hours,"0.0.0.0:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
furyssh,speaches,Up 36 hours,0.0.0.0:8000->8000/tcp,ghcr.io/speaches-ai/speaches:latest-cuda
mcp-gateway,code-server,Up 8 days,"0.0.0.0:8080->8443/tcp, [::]:8080->8443/tcp",lscr.io/linuxserver/code-server:latest
mcp-gateway,dashy,Up 8 days (healthy),"0.0.0.0:9090->8080/tcp, [::]:9090->8080/tcp",lissy93/dashy
mcp-gateway,mcp-gateway,Up 8 days,"0.0.0.0:4000->4000/tcp, [::]:4000->4000/tcp",mcp-stack-mcp-gateway
mcp-gateway,mcp-manual,Up 4 minutes,"0.0.0.0:8181->8000/tcp, [::]:8181->8000/tcp",squidfunk/mkdocs-material
mcp-gateway,mcp-shell,Up 8 days,"0.0.0.0:7681->7681/tcp, [::]:7681->7681/tcp",tsl0922/ttyd:latest
mcp-gateway,netdata,Up 8 days (healthy),"0.0.0.0:19999->19999/tcp, [::]:19999->19999/tcp",netdata/netdata
mcp-gateway,ntopng,Up 8 days,"",ntop/ntopng:latest
mcp-gateway,portainer,Up 8 days,"8000/tcp, 9000/tcp, 0.0.0.0:9443->9443/tcp, [::]:9443->9443/tcp",portainer/portainer-ce:latest
mcp-gateway,termix,Up 8 days,"30001-30006/tcp, 0.0.0.0:18080->8080/tcp, [::]:18080->8080/tcp",ghcr.io/lukegus/termix:latest
mcp-gateway,uptime-kuma,Up 8 days (healthy),"0.0.0.0:3001->3001/tcp, [::]:3001->3001/tcp",louislam/uptime-kuma:1
rotki,dozzle,Up 18 hours,"0.0.0.0:9999->8080/tcp, [::]:9999->8080/tcp",amir20/dozzle:latest
rotki,dozzle-agent,Up 9 days,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
rotki,linkwarden-db,Up 9 days,5432/tcp,postgres:16-alpine
rotki,linkwarden-meilisearch,Up 9 days,7700/tcp,getmeili/meilisearch:v1.12.8
rotki,rotki,Up 9 days (healthy),"0.0.0.0:8085->80/tcp, [::]:8085->80/tcp",rotki/rotki:latest
supabase,dozzle-agent,Up 31 hours,"0.0.0.0:7007->7007/tcp, [::]:7007->7007/tcp, 8080/tcp",amir20/dozzle:latest
supabase,realtime-dev.supabase-realtime,Up 13 days (unhealthy),"",supabase/realtime:v2.34.47
supabase,supabase-analytics,Up 13 days (healthy),"0.0.0.0:4000->4000/tcp, [::]:4000->4000/tcp",supabase/logflare:1.14.2
supabase,supabase-auth,Up 13 days (healthy),"",supabase/gotrue:v2.177.0
supabase,supabase-db,Up 13 days (healthy),5432/tcp,supabase/postgres:15.8.1.060
supabase,supabase-db-forward,Up 11 hours,"0.0.0.0:54322->5432/tcp, [::]:54322->5432/tcp",alpine/socat
supabase,supabase-edge-functions,Up 13 days,"",supabase/edge-runtime:v1.67.4
supabase,supabase-imgproxy,Up 13 days (healthy),8080/tcp,darthsim/imgproxy:v3.8.0
supabase,supabase-kong,Up 13 days (healthy),"0.0.0.0:8000->8000/tcp, [::]:8000->8000/tcp, 8001/tcp, 0.0.0.0:8443->8443/tcp, [::]:8443->8443/tcp, 8444/tcp",kong:2.8.1
supabase,supabase-meta,Up 13 days (healthy),8080/tcp,supabase/postgres-meta:v0.91.0
supabase,supabase-pooler,Up 13 days (healthy),"0.0.0.0:5432->5432/tcp, [::]:5432->5432/tcp, 0.0.0.0:6543->6543/tcp, [::]:6543->6543/tcp",supabase/supavisor:2.5.7
supabase,supabase-rest,Up 13 days,"0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp",postgrest/postgrest:v12.2.12
supabase,supabase-storage,Up 13 days (healthy),5000/tcp,supabase/storage-api:v1.25.7
supabase,supabase-studio,Up 13 days (healthy),3000/tcp,supabase/studio:2025.06.30-sha-6f5982d
supabase,supabase-vector,Up 13 days (healthy),"",timberio/vector:0.28.1-alpine
```

## 7) Points à clarifier / trous connus

- **Cloudflared côté Minecraft** : binaire présent mais pas de config détectée (et `sudo` a échoué lors de la recherche dans `/etc/cloudflared`). Si tu veux, on peut confirmer en root si un tunnel existe réellement.

- **TrueNAS `midclt vm.query`** : la sortie contient des `null` (JSON) qui cassent certains one-liners Python. La commande qui marche est celle que tu as utilisée ensuite (sans f-string avec backslash) — on peut la standardiser.

- **Box2-media** : inventaire confirme peu/pas de conteneurs hors `dozzle-agent` ; si tu veux inclure les images “préinstallées”, il faudrait un export `docker images` sur cette VM.

- **LAN devices `lan-ip-*`** : ce sont des placeholders NetBox (appareils non nommés). Si tu souhaites un schéma “lisible humain”, il faudra les regrouper (IoT, mobiles, etc.) plutôt que les lister individuellement.

## 8) Recommandations (structure documentaire)

- Conserver ce fichier comme **source unique** (inventory), et générer automatiquement une image (Graphviz) à partir de ce MD / d’un JSON normalisé.

- Option robuste : produire un export JSON “canonique” dans Supabase (tables `assets`, `vms`, `containers`, `endpoints`, `tunnels`) puis générer :

  - un schéma *overview* (image)

  - un schéma *inventory* (image)

  - ce MD (texte)
