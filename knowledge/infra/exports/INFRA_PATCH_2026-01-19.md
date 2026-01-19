# BRUCE — Infra Patch (delta) — 2026-01-19

## 0) But

Ce fichier **ne remplace pas** `Bruce_Homelab_Infrastructure_Full.md` (généré le `2026-01-11T18:38:09Z`).
Il documente uniquement :

- la **validation rapide** (ping + endpoints clés) effectuée le `2026-01-19`
- l’ajout du **nouvel ordinateur d’embeddings** non présent dans le “Full” du `2026-01-11`

Source d’exécution de la validation : `furymcp` (UTC).

---

## 1) Validation rapide (réseau)

### 1.1 Pings OK (1 paquet)

Tous ces hôtes ont répondu **OK** :

- `192.168.2.1` (routeur / passerelle LAN)
- `192.168.2.58` (Proxmox Box 1)
- `192.168.2.103` (Proxmox Box 2)
- `192.168.2.183` (TrueNAS SCALE)
- `192.168.2.32` (FurycomAI)
- `192.168.2.190` (poste Windows)
- `192.168.2.206` (supabase-vm)
- `192.168.2.230` (mcp-gateway VM)
- `192.168.2.231` (ROTKI VM)
- `192.168.2.248` (homeassistant VM)
- `192.168.2.87` (box2-edge VM)
- `192.168.2.249` (box2-secrets VM)
- `192.168.2.174` (box2-automation VM)
- `192.168.2.154` (box2-observability VM)
- `192.168.2.113` (box2-docs VM)
- `192.168.2.173` (box2-tube VM)
- `192.168.2.12` (box2-daily VM)
- `192.168.2.123` (box2-media VM)
- `192.168.2.177` (Minecraft VM / TrueNAS)

Nouveauté (embeddings) :

- `192.168.2.85` (Embedder host) — **OK**

---

## 2) Validation rapide (endpoints clés)

### 2.1 MCP Gateway — OK

- `http://192.168.2.230:4000/health`
- Réponse : `{"status":"ok", ... }`

### 2.2 Supabase PostgREST — OK

- `http://192.168.2.206:3000/observed_snapshots?select=id&limit=1`
- Réponse : tableau JSON avec un `id`

### 2.3 Ollama (FurycomAI) — OK

- `http://192.168.2.32:11434/api/tags`
- Réponse : JSON `models[...]`

### 2.4 Embedder (nouveau host) — OK

- `http://192.168.2.85:8081/health`
- Réponse :
  - `ok=true`
  - `model=BAAI/bge-m3`
  - `device=cuda`
  - `fp16=true`
  - `normalize=true`
  - `max_length_default=1024`
  - `dims_expected=1024`

---

## 3) Nouveau host ajouté : “Embedder” (Embeddings/RAG)

### 3.1 Identité / réseau

- Rôle : **machine dédiée embeddings** (service HTTP FastAPI)
- IP : `192.168.2.85`
- SSH : `22/tcp` ouvert
- API : `8081/tcp` ouvert
- Vendor NIC (ARP) : `ASUSTek Computer` (MAC `ac:9e:17:b4:f3:0e`)
- Hostname : non collecté (à faire plus tard si nécessaire)

### 3.2 Service d’embeddings (FastAPI / Uvicorn)

Base URL :

- `http://192.168.2.85:8081`

Endpoints :

- `GET /health`
- `POST /embed`
- `GET /openapi.json`

OpenAPI (extraits utiles) :

- `info.title=FastAPI`
- `info.version=0.1.0`
- `POST /embed` body schema : `EmbedRequest`
  - `inputs` : string OU array[string] (requis)
  - `max_length` : integer|null (optionnel)

### 3.3 Modèle / sortie attendue

- Modèle : `BAAI/bge-m3`
- Dimensions embeddings attendues : `1024`
- Device : `cuda`
- FP16 : `true`
- Normalisation : `true`
- Longueur max par défaut : `1024`

---

## 4) Conclusion (delta vs Full 2026-01-11)

- L’infra “Full” du `2026-01-11` reste **globalement cohérente** : les hôtes clés ont été pingés OK et les endpoints critiques répondent.
- Ajout requis : **nouvelle machine embeddings** `192.168.2.85` + service FastAPI `:8081` (modèle `BAAI/bge-m3`, dims `1024`).
