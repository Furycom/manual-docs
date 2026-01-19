# Backups & snapshots

This page describes the main backup and snapshot strategies used in the homelab.

The goal is to make it easy to recover from mistakes (bad configuration, broken update, etc.) without having to remember dozens of commands.

---

## 1. Proxmox VM snapshots

### 1.1. When to take a snapshot

Take a Proxmox snapshot **before**:

- major OS upgrades on a VM
- large configuration changes (e.g. new Docker stacks)
- experimenting with new tools that may break the system

Typical VMs where snapshots are useful:

- `supabase-vm` (ID 100)
- `rotki` VM (ID 101)
- `homeassistant` VM (ID 102)
- `mcp-gateway` VM (ID 103)
- `n8n-vm` (ID 111)

### 1.2. How to create a snapshot (from Proxmox UI)

1. Open the Proxmox web interface.
2. Select the VM (e.g. `103 mcp-gateway`).
3. Go to **Snapshots**.
4. Click **Take Snapshot**.
5. Choose:
   - a clear name (e.g. `before-mcp-stack-change`)
   - optional description
6. Confirm.

### 1.3. How to revert to a snapshot

1. Open the Proxmox web interface.
2. Select the VM.
3. Go to **Snapshots**.
4. Select the snapshot you want to restore.
5. Click **Rollback**.
6. Confirm and wait for the VM to reboot.

---

## 2. Docker stacks on the MCP VM

The MCP VM (`mcp-gateway`, ID 103) runs several Docker stacks:

- `mcp-stack` in `/home/furycom/mcp-stack`
- `admin-portal` in `/home/furycom/admin-portal`
- `mcp-manual` (this documentation) in `/home/furycom/mcp-manual`

### 2.1. How to restart a stack

From the MCP VM shell:

```bash
# MCP stack (gateway, code-server, ttyd)
cd /home/furycom/mcp-stack
docker compose down
docker compose up -d

# Admin portal (Dashy, Netdata, Portainer)
cd /home/furycom/admin-portal
docker compose down
docker compose up -d

# Manual (MkDocs)
cd /home/furycom/mcp-manual
docker compose down
docker compose up -d

3. Documentation manual refresh

The documentation manual is stored in /home/furycom/mcp-manual and served via MkDocs.

There is a helper script to:

    regenerate auto-generated pages (stacks, etc.)

    restart the MkDocs container

3.1. How to refresh the manual

From the MCP VM shell:

cd /home/furycom/mcp-manual
./manual-refresh.sh

You should run this after:

    changing docker-compose.yml files for MCP stacks

    editing scripts under tools/ that generate documentation

    adding or removing auto-generated pages


