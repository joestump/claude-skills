---
name: cut-release
description: >
  Cut a release on GitHub or Gitea — the forge-level Release object (notes +
  assets) that sits on top of a git tag, NOT just the tag itself. Use this
  skill whenever the user says "cut a release", "cut a tag", "tag a release",
  "ship it", "publish v1.2.0", "do a release", or "draft release notes", and
  especially right after a PR is merged to the default branch when it's time to
  ship. The skill auto-discovers the forge from the git remote (github.com →
  GitHub, anything else → probe for Gitea/Forgejo), verifies CI is green on the
  merge commit before publishing, figures out the next semver tag from the
  repo's existing tag convention and the commits since the last tag, then
  creates an annotated tag and a Release with notes. Works for single-version
  repos and monorepos with per-component tags (like this one:
  `<skill-name>-vX.Y.Z`). Reach for this even if the user only says "tag" —
  confirm whether they want a bare tag or a full release.
category: Dev
tags: [github, gitea, forgejo, release, semver, ci, gh, tea]
status: stable
---

# Cut a Release

A **tag** is a git ref — a name pointing at a commit. A **release** is a
forge-level object (GitHub Release / Gitea Release) that *references* a tag and
adds human-facing notes, a title, and optional binary assets. They are not the
same thing, and the user's "cut a release" almost always means the second:
publish something installable/downloadable with notes, anchored to a tag.

This skill runs one arc regardless of forge:

**discover the forge → verify CI is green → determine the next tag → create the
tag → cut the release → verify & report.**

Only the last-mile API differs between GitHub and Gitea. The decision-making —
which version, is it green, what goes in the notes — is identical, and lives
here in the main file. Forge-specific commands live in the references; read the
one that matches what discovery finds.

## Step 0: Discover the forge and repo

Never assume GitHub. Run discovery first — it tells you which reference file to
read and gives you the `owner`, `repo`, and API base the rest of the steps need.

```bash
scripts/detect-forge.sh
```

It prints `forge` (`github` | `gitea` | `unknown`), `host`, `owner`, `repo`,
`api_base`, and `default_branch`. How it decides:

- Parse `git remote get-url origin` (fall back to the first remote) into
  host/owner/repo, handling both `git@host:owner/repo.git` and
  `https://host/owner/repo.git` forms.
- `host == github.com` (or `gh auth status` knows the host) → **GitHub**.
- Otherwise probe `https://<host>/api/v1/version`. Gitea and Forgejo both answer
  with `{"version":"…"}` → **Gitea** (the Gitea reference covers Forgejo too;
  the API is compatible).
- If the probe fails, it's `unknown`: ask the user which forge this host is, or
  whether it's GitHub Enterprise (in which case set `GH_HOST` and use the GitHub
  path).

Then read the matching reference and keep it open for Steps 2 and 4:

- **GitHub** → `references/github.md` (`gh` CLI first, REST API as fallback)
- **Gitea / Forgejo** → `references/gitea.md` (`tea` CLI first, REST API as fallback)

If discovery returns `unknown` and the user can't clarify, stop — don't guess a
host or push tags into the dark.

## Step 1: Confirm it's a release, and on which commit

Pin down two things before touching versions:

1. **Tag vs. release.** If the user said "tag", ask whether they want a bare
   annotated tag or a full release with notes. Default to a release — that's
   what "cut a release" means and it's the higher-value action. A release always
   implies a tag; a tag does not imply a release.
2. **The target commit.** Releases ship the tip of the default branch by
   default (the just-merged commit). Confirm the branch is the one to release
   from and that local is in sync:
   ```bash
   git fetch origin
   git rev-parse origin/<default_branch>   # the SHA you'll verify and tag
   ```
   If the user wants to release a different commit/branch, use that SHA instead
   throughout.

## Step 2: Verify CI is green — gate the release on it

**Do not cut a release on a red or pending commit.** The whole point of tying
releases to merges is that you only ship what passed. Check the combined status
*and* check-runs for the target SHA — a commit can have passing legacy statuses
but a failing check-run, or vice versa.

The exact commands are in the forge reference (`references/github.md` →
"Verify CI", `references/gitea.md` → "Verify CI"). The decision rule is the same:

- **All green** → proceed.
- **Pending / in-progress** → wait and re-check; don't release mid-run. Tell the
  user it's still running rather than pushing ahead. Do not block with `sleep`
  loops indefinitely — re-check a couple of times, then report status and let the
  user decide whether to wait.
- **Failing** → stop. Report which check failed with a link. A failing default
  branch is a bug to fix, not a release to cut.

If the repo genuinely has no CI configured, say so explicitly and ask the user
to confirm they want to release without a green signal — don't silently skip the
gate.

## Step 3: Determine the next tag

Follow the repo's existing convention rather than inventing one. Inspect what's
already there:

```bash
git tag --sort=-v:refname | head -20
```

Identify the pattern and pick the next version:

- **Plain semver** (`v1.4.2` or `1.4.2`) — single-version repo. Match the
  existing `v`-prefix-or-not exactly.
- **Per-component / monorepo** (`<component>-vX.Y.Z`, e.g. this repo's
  `retirement-plan-v1.1.0`) — releases are scoped to one component. Determine
  *which* component changed since its last tag (look at the paths in
  `git diff --name-only <last-tag>..origin/<default_branch>`) and bump only that
  component's tag. One component per release — never bundle two into one tag.
  See `references/versioning.md` for the monorepo walkthrough.

Choose MAJOR/MINOR/PATCH from the commits since the last matching tag:

```bash
git log <last-tag>..origin/<default_branch> --pretty=format:'%s%n%b'
```

- Breaking change (a `!` in the type, a `BREAKING CHANGE:` footer, or a removed/
  renamed public contract) → **MAJOR**.
- New feature (`feat:`, an added capability) → **MINOR**.
- Fixes / docs / internal only (`fix:`, `chore:`, `docs:`) → **PATCH**.

If commits aren't conventional, read the diff and judge by impact. **Propose the
computed version and one-line reasoning, and get the user's confirmation before
tagging** — a version bump is a public, hard-to-walk-back claim about
compatibility. Details and edge cases in `references/versioning.md`.

## Step 4: Check for release automation, then create tag + release

Before cutting anything by hand, check whether the repo already automates
releases on tag push — many do (this repo's `.github/workflows/release-skill.yml`
fires on `*-v*.*.*` tags and builds the Release itself).

```bash
ls .github/workflows .gitea/workflows .forgejo/workflows 2>/dev/null
```

Grep any workflow for a tag trigger (`on: push: tags:`) that creates a release.
**If release automation exists**, the correct move is to *only* push the tag and
let the pipeline cut the release — doing it by hand would double-create or fight
the automation. In that case:

1. Create an **annotated** tag on the target SHA and push it:
   ```bash
   git tag -a "<tag>" <sha> -m "<tag>"
   git push origin "<tag>"
   ```
2. Then jump to Step 5 and verify the automation produced the Release.

**If there's no automation**, create the tag and the release yourself using the
forge reference's "Create the release" section. Prefer letting the release
command create the tag from the target commit when it can (both `gh release
create` and the Gitea API do), so the tag and release are atomic — or push an
annotated tag first if you want the tag to exist independently. Either way:

- Title: the tag, or `<component> <version>` for monorepos.
- Notes: auto-generate from commits/PRs where the forge supports it
  (`--generate-notes` on GitHub, the changelog from Step 3 on Gitea), then tidy
  into a short human summary. Lead with what changed and how to install/upgrade
  if relevant.
- `prerelease: true` for `-rc`/`-beta`/`-alpha` tags; `draft: true` only if the
  user wants to review notes before it goes public.
- Attach assets only if the repo ships build artifacts; the reference shows how.

## Step 5: Verify and report

Confirm the Release actually exists on the forge (not just the tag) and report
its URL — the reference's "Verify" section has the exact command. Then summarize:

```
✓ Forge: GitHub (github.com/joestump/claude-skills)
✓ CI green on a1b2c3d (default branch: main)
✓ Tagged retirement-plan-v1.2.0 (annotated) and pushed
✓ Release cut: retirement-plan v1.2.0
  → https://github.com/joestump/claude-skills/releases/tag/retirement-plan-v1.2.0
  → notes: 3 PRs, 1 feature, 2 fixes
```

If automation cut the release, say so and link it once it appears (it may take a
few seconds for the workflow to run — check the Actions/run list if it's not up
yet). On any failure, name the exact step and the error, and do not leave a
dangling tag without a release without telling the user — either finish cutting
the release or call out that the tag exists but the release didn't get made.

## Triggers worth acting on

Beyond an explicit "cut a release", proactively offer to run this skill when:

- A PR was just merged to the default branch and CI is green ("want me to cut a
  release for this?").
- The user says "ship it", "publish", "tag a release", "draft release notes".
- There are unreleased commits on the default branch past the last tag and the
  user is wrapping up work.

Always confirm the version bump before publishing — the verify-green gate and the
version confirmation are the two non-negotiable checkpoints.

## Reference files

- `references/github.md` — GitHub via `gh` and the REST API: verify CI, create
  tag + release, generate notes, attach assets, GitHub Enterprise notes.
- `references/gitea.md` — Gitea/Forgejo via `tea` and the REST API: auth,
  verify CI, create tag + release, attach assets.
- `references/versioning.md` — semver decisions, monorepo per-component tags,
  changelog generation, prerelease handling, and what to do when commits aren't
  conventional.
- `scripts/detect-forge.sh` — forge/owner/repo discovery from the git remote.
