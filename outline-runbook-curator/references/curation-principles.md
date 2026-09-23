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

The infrastructure repo is ground truth. Ask the user for its checkout path if it isn't already
in context -- don't assume one:

- `docs/adrs/ADR-XXXX-*.md` -- the ADRs runbooks cite. **Verify every citation against the actual
  file** before trusting an Outline claim.
- `decisions/` -- base decisions (node management, service role, inventory source of truth).
- the per-site inventory files (one per site, each mapping hosts to the services they run), plus
  `roles/`, for host/service facts.
- `docs/guides/`, `docs/apps/`, `docs-site/` -- user-facing/narrative material that may belong in
  the wiki but isn't there yet.

When repo and Outline disagree, **fix Outline**. Don't delete history -- tombstone with a dated
`:::warning` "retired / replaced by ..." callout, and move retired apps under `Deprecated`.

## Handling stale references

Migrations leave the wiki describing a world that no longer exists. Treat every such reference as
a question for the repo, not a fact of its own:

- **Confirm the migration in the repo before acting.** The ADR or decision record that retired the
  old thing is the authority -- not the runbook's prose about it.
- **Already tombstoned is already correct.** A doc carrying a dated `:::warning` "retired /
  replaced by ..." callout needs nothing further; don't re-flag it.
- **Pet names are not stale references.** A live pool, host, or service with an unusual name reads
  as wrong to anyone who doesn't know the fleet. Check the inventory before "fixing" one.
- **Leave genuine judgment calls in the doc for a human.** Contradictions you can't resolve from
  the repo -- a management IP that disagrees with the current subnet, a credential that looks like
  a vendor default -- stay as an in-doc flag and go in your summary. Don't guess at the answer, and
  don't copy the specifics anywhere the wiki's own access boundary doesn't already cover.

If the fleet has a known set of completed migrations worth tracking across sessions, keep that
watchlist in the wiki itself or in a private companion skill. It doesn't belong here: it would go
stale on the next migration, and it would publish the fleet's shape to everyone who reads the
skill.
