---
sidebar_position: 1
title: Getting started
---

# Getting started

`claude-skills` is a personal mono-repo of [Claude](https://claude.ai) skills. Each top-level directory in the [GitHub repo](https://github.com/joestump/claude-skills) is one self-contained skill: an instruction pack Claude loads on demand.

## What's a skill?

A skill is a folder with:

- A `SKILL.md` — the instructions Claude follows when the skill triggers.
- A `README.md` — human-readable overview.
- Optional `references/` — additional docs Claude pulls in for specific phases (interview flow, design spec, self-evaluation thresholds, etc.).
- Optional `assets/` — templates, fixtures, anything Claude reads at render time.
- Optional `scripts/` — shell scripts the skill shells out to.

The first paragraph of every `SKILL.md` description is what Claude reads to decide whether the skill applies to a request. That's the trigger contract.

## Install a skill

### Claude Code

Drop the skill directory into `~/.claude/skills/`:

```sh
git clone https://github.com/joestump/claude-skills.git
cp -r claude-skills/retirement-plan ~/.claude/skills/
```

Claude Code picks it up on the next session. No restart needed.

### Claude.ai (web / desktop)

1. Download the skill's `.zip` from the [Releases page](https://github.com/joestump/claude-skills/releases) — or zip the directory yourself.
2. Open Claude → Settings → Capabilities → Skills → Upload.
3. Drop the zip in.

## Versioning

Skills version independently using per-skill tags:

```
<skill-name>-v<MAJOR>.<MINOR>.<PATCH>
```

Examples:

- `retirement-plan-v1.0.0`
- `retirement-plan-v1.1.0`

When you push a tag matching `*-v*.*.*`, [a workflow](https://github.com/joestump/claude-skills/blob/main/.github/workflows/release-skill.yml) zips the matching skill directory and publishes it as a GitHub Release with install instructions in the notes.

## Browse the skills

- [retirement-plan](/docs/retirement-plan) — high-fidelity retirement plan artifact builder.
- [self-report](/docs/self-report) — files GitHub issues when a skill hits friction.
