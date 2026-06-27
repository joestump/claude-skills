# Curation principles

## Hierarchy-native structure

- **Shared qualifier => missing parent.** If sibling docs share a term (e.g. several "Proxmox X"
  docs, or "Servers & GPUs" covering two different things), that shared term wants to be a
  **parent node**. Create it and nest the children.
- **Theme-based grouping.** Group by topic, not by mechanical splitting. Example (Hardware):
  three sibling sub-nodes -- **Servers**, **GPUs**, **Personal Devices**. GPUs is its **own**
  category alongside Servers and Personal Devices (the GPU cards + GPU chassis), not folded into
  Servers.
- **Parent bodies orient; leaves distinguish.** A parent node gets a short body that says what the
  domain covers and links its children (a child index). Leaf titles must not repeat what the
  breadcrumb already supplies; each leaf body leads with its own distinguishing detail.
- **Read before edit; patch, don't replace.** `fetch` the doc, then `update_document` with
  `editMode: "patch"` and verbatim `findText`. Reserve `replace` for empty/one-line bodies.

## Repo-wins reconciliation

The repo at `/Users/joestump/src/stumpcloud/infra` is ground truth:

- `docs/adrs/ADR-XXXX-*.md` -- the ADRs runbooks cite. **Verify every citation against the actual
  file** before trusting an Outline claim.
- `decisions/` -- base decisions (node management, service role, inventory source of truth).
- inventory: `dub.yaml` (Dublin / `.stump.rocks`), `dtw.yaml` (Detroit / `.stump.wtf`), `pdx.yaml`
  (Portland-Vancouver / `.stump.wtf`); `roles/` for host/service facts.
- `docs/guides/`, `docs/apps/`, `docs-site/` -- user-facing/narrative material that may belong in
  the wiki but isn't there yet.

When repo and Outline disagree, **fix Outline**. Don't delete history -- tombstone with a dated
`:::warning` "retired / replaced by ..." callout, and move retired apps under `Deprecated`.

## Known stale-reference watchlist (as of 2026-06)

These migrations are done; in Outline they should already be tombstoned. Verify they are; don't
re-flag what's already correctly marked historical.

| Was | Now | Authority |
|-----|-----|-----------|
| PDX site hosts `ext01`, `gpu01`, `int01`, `media01`, `nuc02` | decommissioned; `nuc01` only survivor | ADR-0024 |
| Authentik (`id.stump.wtf`) | Pocket ID v2 (`identity.stump.rocks`) + oauth2-proxy | ADR-0018 |
| MinIO | Garage S3 (tiered multi-site) | ADR-0008, ADR-0025 |
| Infisical | OpenBao (3-node HA Raft) | ADR-0017, ADR-0026, ADR-0027 |
| TubeSync | Pinchflat (on `ie01`) | (Arr Clients runbook) |
| TrueNAS | Proxmox VE + plain ZFS pools (`voltron`/`tank`/`critical`) | ADR-0021 |

**Looks-stale-but-isn't -- do NOT "fix":** `voltron` is the live DUB media ZFS pool; `zarkon` is a
live R720xd. Pet names are legitimate here.

**Open flags left in-doc (need a human):** R720xd iDRAC IPs are `192.168.1.x` while current DUB
storage is `192.168.5.x` (VLAN renumber vs stale BMC?); SuperMicro GPU Server still has default
`ADMIN`/`ADMIN` IPMI creds.

## Final tree snapshot (post-curation, 2026-06-27)

```
Runbooks
  Claude -> Outline MCP -> {Claude Code, Claude Desktop}
  Networking -> WireGuard/VPN
  Infrastructure
    Docker, AWS, Monitoring, Bootstrapping Nodes, Proxmox,
    WAF / Edge Security, NUCs Proxmox Install, Proxmox Backup Server
    File Systems -> {ZFS, Extending an LVM's Size}
    Services -> {Garage S3 Object Store, Mosquitto}
    Proxmox Storage & VM Disks -> {Restic}
  Notifications -> SMTP2GO
  Applications
    Paperless, Outline, Arr Clients
    Deprecated -> {TubeSync, Authentik, WireGuard Portal}
  Hardware
    Servers -> {Dell R720xd, Lenovo ThinkPad M93p}
    GPUs -> {SuperMicro GPU Server, NVIDIA Tesla P40}
    Personal Devices -> {Kobo, Nelko Label Makers, K39}
  Home Assistant -> {Living Room Tablet, Two TVs, Rebooting After Power Outages, Devices}
OMGs (sibling top-level) -> incident docs
```
