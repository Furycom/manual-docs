# Bruce Homelab — Inventaire & Structure (MD)

**Généré le :** 2026-01-19T23:34:00Z

Ce document regroupe l’inventaire *le plus complet possible* à partir des exports et vérifications SSH partagés dans cette conversation.

---

## 1) Nœuds / Machines (LAN)

### 1.1 Réseau / Router
- **Router / Gateway** : `192.168.2.1`

### 1.2 Serveurs physiques / NAS / postes
- **Proxmoxbox1** : `192.168.2.58` (Proxmox)
- **Proxmoxbox2** : `192.168.2.103` (Proxmox)
- **TrueNAS** : `192.168.2.183` (TrueNAS SCALE)
- **FurycomAI** : `192.168.2.32` (GPU/LLM)
- **Poste Windows** : `192.168.2.190` (Windows)
- **Embedder host** : `192.168.2.85` (Nouveau host embeddings)

---

## 2) VMs (d’après l’inventaire NetBox / naming convention “box2-*”)

### 2.1 supabase-vm
- **Nom** : `supabase-vm`
- **IP** : `192.168.2.206`
- **Rôle** : Supabase (PostgREST, etc.)

### 2.2 mcp-gateway-vm
- **Nom** : `mcp-gateway VM`
- **IP** : `192.168.2.230`
- **Rôle** : MCP Gateway (health endpoint, routes BRUCE)

### 2.3 ROTKI
- **Nom** : `ROTKI VM`
- **IP** : `192.168.2.231`

### 2.4 homeassistant
- **Nom** : `homeassistant VM`
- **IP** : `192.168.2.248`

### 2.5 box2-edge
- **Nom** : `box2-edge VM`
- **IP** : `192.168.2.87`

### 2.6 box2-secrets
- **Nom** : `box2-secrets VM`
- **IP** : `192.168.2.249`

### 2.7 box2-automation
- **Nom** : `box2-automation VM`
- **IP** : `192.168.2.174`

### 2.8 box2-observability
- **Nom** : `box2-observability VM`
- **IP** : `192.168.2.154`

### 2.9 box2-docs
- **Nom** : `box2-docs VM`
- **IP** : `192.168.2.113`

### 2.10 box2-tube
- **Nom** : `box2-tube VM`
- **IP** : `192.168.2.173`

### 2.11 box2-daily
- **Nom** : `box2-daily VM`
- **IP** : `192.168.2.12`

### 2.12 box2-media
- **Nom** : `box2-media VM`
- **IP** : `192.168.2.123`

### 2.13 Minecraft VM
- **Nom** : `Minecraft VM / TrueNAS`
- **IP** : `192.168.2.177`

---

## 3) Services clés (endpoints)

### 3.1 MCP Gateway
- **Base URL** : `http://192.168.2.230:4000`
- **Health** : `GET /health`

### 3.2 Supabase PostgREST
- **Base URL** : `http://192.168.2.206:3000`
- Exemple :
  - `GET /observed_snapshots?select=id&limit=1`

### 3.3 Ollama (FurycomAI)
- **Base URL** : `http://192.168.2.32:11434`
- Exemple :
  - `POST /api/generate`
  - `GET /api/tags`

### 3.4 Embedder (Nouveau)
- **Base URL** : `http://192.168.2.85:8081`
- **Health** : `GET /health`
- **Embed** : `POST /embed`

---

## 4) Conteneurs Docker (résumé)

> NB: Liste dérivée des `docker ps` fournis dans la session et du snapshot d’inventaire.

### 4.1 FurycomAI (`192.168.2.32`)
- **Ollama** (port `11434`)
- Autres conteneurs LLM / UI selon stack (OpenWebUI, etc.) si présents

### 4.2 supabase-vm (`192.168.2.206`)
- Stack Supabase self-hosted (postgrest, kong, auth, storage, realtime, etc.)

### 4.3 mcp-gateway-vm (`192.168.2.230`)
- MCP Gateway Node/Express (port `4000`)
- Jobs / worker scripts (bruce_cmd_worker, timers systemd, etc.)

### 4.4 box2-observability (`192.168.2.154`)
- Uptime Kuma
- Dozzle agent
- Autres services observabilité (selon déploiement)

### 4.5 box2-docs (`192.168.2.113`)
- Paperless-ngx / BookStack (selon état)
- Dozzle agent

### 4.6 box2-automation (`192.168.2.174`)
- n8n (selon état)
- Dozzle agent

---

## 5) Détails techniques (réseau, ports, vérifs)

### 5.1 Pings / disponibilité (2026-01-19)
- Tous les hôtes “core” pingés ont répondu OK :
  - `192.168.2.1`, `.58`, `.103`, `.183`, `.32`, `.190`, `.206`, `.230`, `.231`, `.248`, `.87`, `.249`, `.174`, `.154`, `.113`, `.173`, `.12`, `.123`, `.177`
- **Nouveau** : `192.168.2.85` (Embedder host) — ping OK

### 5.2 Uptime Kuma — liste des monitors (table)

| Monitor | Type | URL / Target | Interval | Status | Notes |
|--------|------|--------------|----------|--------|-------|
| mcp-gateway health | HTTP(s) | `http://192.168.2.230:4000/health` | 60s | OK | endpoint MCP |
| supabase postgrest | HTTP(s) | `http://192.168.2.206:3000/` | 60s | OK | PostgREST |
| ollama tags | HTTP(s) | `http://192.168.2.32:11434/api/tags` | 60s | OK | LLM models list |
| embedder health | HTTP(s) | `http://192.168.2.85:8081/health` | 60s | OK | Nouveau service embeddings |
| ping router | Ping | `192.168.2.1` | 60s | OK | gateway |
| ping proxmox1 | Ping | `192.168.2.58` | 60s | OK | Proxmox Box 1 |
| ping proxmox2 | Ping | `192.168.2.103` | 60s | OK | Proxmox Box 2 |
| ping truenas | Ping | `192.168.2.183` | 60s | OK | NAS |
| ping furycomai | Ping | `192.168.2.32` | 60s | OK | GPU/LLM host |
| ping supabase | Ping | `192.168.2.206` | 60s | OK | supabase-vm |
| ping gateway | Ping | `192.168.2.230` | 60s | OK | mcp-gateway |
| ping embedder | Ping | `192.168.2.85` | 60s | OK | embeddings |

---

## 6) Nouveau host “Embedder” (embeddings RAG)

### 6.1 Identité / réseau
- **IP** : `192.168.2.85`
- **Rôle** : machine dédiée embeddings (service HTTP FastAPI)
- **SSH** : `22/tcp`
- **API** : `8081/tcp`
- **NIC vendor (ARP)** : `ASUSTek Computer` (MAC `ac:9e:17:b4:f3:0e`)
- **Hostname** : non collecté (à faire si nécessaire)

### 6.2 Service embeddings (FastAPI / Uvicorn)
- **Base URL** : `http://192.168.2.85:8081`
- **Endpoints** :
  - `GET /health`
  - `POST /embed`
  - `GET /openapi.json`

### 6.3 Paramètres modèle
- **Modèle** : `BAAI/bge-m3`
- **Dimensions attendues** : `1024`
- **Device** : `cuda`
- **FP16** : `true`
- **Normalize** : `true`
- **max_length_default** : `1024`

---

## 6b) Notes d’implémentation (RAG embeddings)

- Le host embedder est conçu pour prendre en charge les requêtes embeddings de la stack BRUCE (indexation RAG).
- Il doit être référencé dans la documentation “embeddable scope” et dans toute config qui appelle le service d’embeddings.


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
