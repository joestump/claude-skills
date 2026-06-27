---
name: outline-runbook-curator
description: >
  Curate, consolidate, and restyle the StumpCloud Runbooks wiki in Outline
  (outline.stump.rocks) against the repo as source of truth. Use this skill whenever the user
  wants to review/clean up the wiki, consolidate or reorganize runbooks, fix stale or duplicated
  docs, reconcile Outline against the repo (ADRs, inventory, docs/), restructure the doc tree
  into hierarchy-native nodes, or apply the domain color + topical icon scheme to wiki nodes.
  Trigger on phrases like "audit the runbooks", "clean up the wiki", "consolidate the Outline
  docs", "the wiki is out of date", "reorganize/restyle the Runbooks collection", or "color and
  icon the docs". This is the governance/curation counterpart to the `stumpcloud-omg` skill
  (which files individual incidents); use that for postmortems, this for whole-collection
  curation. Always propose a consolidation plan and get approval before any destructive
  merge/move/delete.
---

# Outline Runbook Curator

Keep the StumpCloud **Runbooks** wiki accurate, well-structured, and consistently styled. The
repo is the source of truth; Outline summarizes it for humans. This skill runs the same arc every
time: **discover (read-only) -> propose a plan -> get approval -> execute -> restyle -> verify.**

The collection: **StumpCloud / Runbooks**, id `1eb79152-f92b-4a7f-bb27-b6c009521790` (with `OMGs`
as a sibling top-level section under the same collection). Always start with
`list_collection_documents` on it to get the current tree.

House voice for wiki bodies: clear, operational, lightly dry -- but the wiki is reference
material, so keep asides minimal. Facts and links are sacred. Blameless framing carries over from
OMGs.

---

## The arc

### 1. Discover (read-only -- never edit in this phase)

- `list_collection_documents` the Runbooks collection for the live tree.
- `fetch` each doc you intend to touch and note: current icon/color, ADR/SPEC citations, stale
  references (decommissioned PDX hosts, retired Authentik/MinIO/Infisical/TubeSync, etc.),
  duplication with siblings, and thin/empty parent bodies.
- Gather repo ground truth from `/Users/joestump/src/stumpcloud/infra`: `docs/adrs/` (the ADRs the
  runbooks cite -- verify the claim against the actual file), `decisions/`, `docs/` and
  `docs-site/` (narrative + user-facing guides), and the inventory (`dub.yaml`, `dtw.yaml`,
  `pdx.yaml`) + `roles/` for host/service facts.
- For large trees, fan this out to subagents (one per section) that each return a concise
  per-doc report -- don't read 40 docs inline.

### 2. Propose a plan -- get approval before anything destructive

Summarize, in prose: what should merge/move/retire, every repo-vs-Outline discrepancy you'd
correct, and any genuine judgment calls (with your recommended default). **Do not** execute
merges, moves, or deletes until the user signs off. Low-risk, reversible moves can be batched
once the overall plan is approved.

### 3. Execute

- **Read before you edit. Prefer `editMode: "patch"`** with `findText` copied verbatim, so rich
  formatting (highlights, comments, table widths) survives. Use `replace` only for empty/one-line
  bodies you're fully rewriting.
- Moves: `move_document` (set `parentDocumentId`). Retire: `delete_document` (trashes,
  recoverable) -- prefer moving retired apps under a **Deprecated** node over deleting them.
- When repo and Outline disagree, **the repo wins** -- correct the Outline doc and flag it in the
  summary. Don't silently delete history; tombstone it (a dated `:::warning` "retired/replaced
  by..." callout) instead.

### 4. Restyle

Color and icon every node per `references/styling-conventions.md`. Do this only after the
structure has settled.

### 5. Verify & report

`list_collection_documents` again to confirm the final tree. Deliver: what merged/moved/retired,
discrepancies corrected, and the final tree (with icons).

---

## Core principles (full detail in `references/`)

- **Hierarchy-native** (`references/curation-principles.md`): where sibling docs share a
  qualifier, that shared term is a missing **parent** -- create it and nest. Leaf titles shouldn't
  repeat what the breadcrumb already supplies. Parent nodes get a short orienting body that links
  their children; each child leads with its own distinguishing detail.
- **Repo wins** (`references/curation-principles.md`): `docs/adrs/`, `decisions/`, inventory, and
  `docs/` are ground truth. Verify every ADR citation against the real file.
- **Styling** (`references/styling-conventions.md`): fixed per-domain colors on top-level nodes;
  each child gets its **own distinct topical color** (not a mechanical lightening of the parent);
  topical emoji per doc with **no generic-icon reuse across siblings**. **OMG severity colors are
  reserved -- never restyle incident docs** (see the `stumpcloud-omg` skill).

## Related skills & references

- `stumpcloud-omg` -- files individual incidents into `Runbooks / OMGs`. Its
  `references/outline-formatting.md` is the canonical Outline markdown/callout cheat-sheet; reuse
  it rather than duplicating. Its severity color scheme is **off-limits** to this skill.
- `references/styling-conventions.md` -- the domain colors, intra-domain color rule, icon rules.
- `references/curation-principles.md` -- hierarchy-native structure, repo-wins reconciliation, the
  read-before-edit / patch discipline, and the known stale-reference watchlist.
