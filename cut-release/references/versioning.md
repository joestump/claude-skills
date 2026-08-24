# Versioning, monorepos, and changelogs

The goal: pick a tag the repo's future self will understand, anchored to the
convention already in use. Never introduce a new scheme without the user asking.

## Read the existing convention first

```bash
git tag --sort=-v:refname | head -30
```

Match what you see — including the `v` prefix or its absence, and any component
prefix. The three common shapes:

| Existing tags | Scheme | Next after a feature |
|---|---|---|
| `v1.4.2`, `v1.4.1` | plain semver, `v`-prefixed | `v1.5.0` |
| `1.4.2`, `1.4.1` | plain semver, no prefix | `1.5.0` |
| `retirement-plan-v1.1.0` | per-component (monorepo) | `retirement-plan-v1.2.0` |

If there are **no tags yet**, start at `v0.1.0` (or `0.1.0` to match repo style),
or `1.0.0` if the user says it's the first stable release. Confirm with the user.

## Choosing MAJOR / MINOR / PATCH (semver)

Look at the commits since the last matching tag and judge by impact on the
*public contract* (API, CLI flags, file formats, skill behavior):

```bash
git log <last-tag>..origin/<default_branch> --pretty=format:'%h %s'
```

- **MAJOR** — a breaking change: removed/renamed a public function/flag/field,
  changed output format incompatibly, a `feat!:`/`fix!:` type, or a
  `BREAKING CHANGE:` footer.
- **MINOR** — backward-compatible new capability: `feat:`, a new flag/tab/option.
- **PATCH** — fixes and internal-only work: `fix:`, `docs:`, `chore:`,
  `refactor:`, `test:`.

When in doubt between two levels, prefer the higher one — under-bumping hides a
breaking change from downstream and is the more expensive mistake.

**Conventional Commits** make this mechanical, but many repos don't use them.
When prefixes are absent or inconsistent, read the actual diff
(`git diff <last-tag>..origin/<default_branch>`) and decide by what changed.
Either way, **state the computed version and a one-line reason, and get the
user's confirmation before tagging** — the bump is a public compatibility claim.

## Monorepo / per-component tags

When tags are `<component>-vX.Y.Z` (like this repo, where each top-level skill
directory versions independently), a release is scoped to **one** component:

1. Find which component(s) changed since their last tag:
   ```bash
   # For a candidate component dir, what changed since its last tag?
   last=$(git tag --sort=-v:refname | grep "^COMPONENT-v" | head -1)
   git diff --name-only "${last:-$(git rev-list --max-parents=0 HEAD)}"..origin/<default_branch> -- COMPONENT/
   ```
2. If several components changed, cut **one tag per component** — never bundle
   two components into a single tag. Ask the user which to release if it's
   ambiguous, or release each in turn.
3. Compute the bump from commits touching *that component's* path only:
   ```bash
   git log "${last}..origin/<default_branch>" --pretty=format:'%h %s' -- COMPONENT/
   ```
4. The tag is `COMPONENT-vNEW`; the release title is usually `COMPONENT vNEW`.

This repo's convention is documented in its root `CLAUDE.md` ("Versioning &
tagging") and enforced by `.github/workflows/release-skill.yml`, which parses
the component name from the tag and zips that directory into the release. When
you push a `COMPONENT-vX.Y.Z` tag here, **that workflow cuts the release** — so
push the tag and verify, don't hand-create the release.

## Prereleases

Tags with a suffix — `-rc.1`, `-beta.2`, `-alpha` — are prereleases. Mark them
`prerelease: true` (`--prerelease`) so the forge doesn't surface them as the
"latest" release. Semver orders `1.2.0-rc.1` *before* `1.2.0`.

## Changelog

GitHub can auto-generate notes from merged PRs (`--generate-notes`). Gitea
can't, so build the changelog from commits and pass it as the release body:

```bash
git log <last-tag>..origin/<default_branch> \
  --no-merges --pretty=format:'- %s (%h)' -- [COMPONENT/]
```

Group into **Features / Fixes / Other** when there's enough to warrant it, lead
with a one-line summary of what this release is, and add an install/upgrade note
if the repo ships something installable. Keep it human — the raw commit dump is
a starting point, not the final notes.

## Annotated vs lightweight tags

Always create **annotated** tags (`git tag -a`), not lightweight ones. Annotated
tags carry a tagger, date, and message — they're real objects, show up properly
in `git describe`, and are what release tooling expects. Lightweight tags are
just a moving pointer and lose all that metadata.
