# Styling conventions (color + icon)

Every node in the Runbooks collection gets a topical **emoji `icon`** and a hex **`color`**, both
set via `update_document` (pass `icon` = emoji and `color` = hex; pass `null` to clear). The web
icon picker doesn't expose color, but the API does -- same mechanism the OMG severity color uses.

## Rule 1 -- top-level domains get a fixed color

Each top-level node under `Runbooks` (and the `OMGs` sibling) has ONE reserved color:

| Domain | Color | Icon |
|--------|-------|------|
| Networking | `#3B82F6` (blue) | 🌐 |
| Infrastructure | `#22C55E` (green) | 🏗️ |
| Applications | `#A855F7` (purple) | 🗂️ |
| Notifications | `#F59E0B` (amber) | 🔔 |
| Claude / Outline-MCP | `#6366F1` (indigo) | 🤖 |
| Hardware | `#64748B` (slate) | 🔧 |
| Home Assistant | `#14B8A6` (teal) | 🏠 |
| OMGs / incidents | `#EF4444` (red) | 🆘 |

## Rule 2 -- each child gets its OWN distinct topical color

Children and grandchildren do **not** inherit a lightened parent hue. Pick a color that fits the
*doc's topic* (Docker -> docker blue `#2496ED`, AWS -> aws orange `#FF9900`, NVIDIA -> nvidia green
`#76B900`, Garage S3 -> bucket amber `#EAB308`, etc.). Within any sibling group, colors **and**
icons must be distinct; cross-group reuse is fine.

## Rule 3 -- topical emoji, no generic icon across siblings

Diversify icons by topic. Never reuse one generic icon across a set of siblings. Emoji are the
default (they round-trip through the API cleanly). Match the thing: 🐳 Docker, 🪣 S3, 🦟 Mosquitto,
🚀 bootstrap, 🛡️ WAF, 💾 disks, ♻️ backup, etc.

## Rule 4 -- Deprecated nodes

The `Deprecated` parent is muted gray `#6B7280` with ⚠️. Its children keep their own topical
colors but each must carry a dated `:::warning` "retired / replaced by ..." banner at the top.

## Rule 5 -- OMG severity colors are RESERVED

Do **not** restyle OMG incident docs. Their `color` encodes severity (Huge `#D0021B` -> Big -> Medium
-> Small -> Tiny `#00D084`; see the `stumpcloud-omg` skill's `posting-to-outline.md`). The `OMGs`
parent is `#EF4444`. Leave all of this alone.

---

## Applied snapshot (2026-06-27) -- the scheme as it currently stands

Reuse these so future sessions don't re-derive. Format: `Title  ICON  COLOR`.

```
Claude                       🤖 #6366F1
  Outline MCP                🔌 #8B5CF6
    Claude Code              💻 #0EA5E9
    Claude Desktop           🖥️ #38BDF8
Networking                   🌐 #3B82F6
  WireGuard/VPN              🔐 #0891B2
Infrastructure               🏗️ #22C55E
  Docker                     🐳 #2496ED
  AWS                        ☁️ #FF9900
  File Systems               🗄️ #15803D
    ZFS                      💽 #0D9488
    Extending an LVM's Size  📀 #84CC16
  Services                   🧩 #10B981
    Garage S3 Object Store   🪣 #EAB308
    Mosquitto                🦟 #06B6D4
  Monitoring                 📊 #8B5CF6
  Bootstrapping Nodes        🚀 #F97316
  Proxmox                    🧰 #BE123C
  WAF / Edge Security        🛡️ #DC2626
  NUCs Proxmox Install       🖥️ #0891B2
  Proxmox Backup Server      🗃️ #7C3AED
  Proxmox Storage & VM Disks 💾 #2563EB
    Restic                   ♻️ #DB2777
Notifications                🔔 #F59E0B
  SMTP2GO                    ✉️ #EA580C
Applications                 🗂️ #A855F7
  Paperless                  📄 #0284C7
  Outline                    📖 #0D9488
  Arr Clients                🍿 #E11D48
  Deprecated                 ⚠️ #6B7280
    TubeSync                 ▶️ #EF4444
    Authentik                🔑 #FB923C
    WireGuard Portal         🚇 #6D28D9
Hardware                     🔧 #64748B
  Servers                    🧱 #475569
    Dell R720xd              🗄️ #0F766E
    Lenovo ThinkPad M93p     💻 #B91C1C
  GPUs                       🧠 #4D7C0F
    SuperMicro GPU Server    🧊 #1E40AF
    NVIDIA Tesla P40         ⚙️ #76B900
  Personal Devices           🎒 #94A3B8
    Kobo                     📚 #1D4ED8
    Nelko Label Makers       🏷️ #059669
    K39                      🎮 #9333EA
Home Assistant               🏠 #14B8A6
  Living Room Tablet         📱 #0EA5E9
  Two TVs                    📺 #8B5CF6
  Rebooting After Outages    ⚡ #FBBF24
  Devices                    🔌 #10B981
OMGs (reserved scheme)       🆘 #EF4444
```
