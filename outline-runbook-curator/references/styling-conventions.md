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

## Recording the applied scheme

Once a collection is styled, the per-doc icon and color assignments are worth recording so later
sessions don't re-derive them -- but record them **in the wiki**, not in this skill. A parent
node's body or a dedicated styling doc inside the collection is the right home: it sits next to
what it describes, and it inherits the collection's own access boundary.

A snapshot pasted into the skill goes stale the moment the tree changes, and it publishes the
shape of a private wiki -- every doc title, including the ones about someone's house -- to
everyone who can read the skill.
