---
sidebar_position: 3
title: self-report
---

# self-report

Single owner of the "skill in this repo hit friction → file a GitHub issue" workflow. Other skills in this repo delegate to it rather than implementing their own filing logic, so label management, the issue body format, the privacy filter, and the GitHub MCP / `gh` / fallback tier chain all live in one place.

[**Source on GitHub →**](https://github.com/joestump/claude-skills/tree/main/self-report)

## How it triggers

`self-report` is mostly invoked by **other skills**, not by you directly:

- A skill in this repo hits one of its own trip thresholds (defined in that skill's `references/self-eval.md`) and hands off to `self-report` with a skill name, a short title, and a body.
- You explicitly invoke `/self-report`.

It does **not** self-report. Filing-about-filing is a recursion trap; if `self-report` itself fails, the calling agent surfaces the failure to you in chat.

## Multi-skill runs

If two or more skills from this repo run in the same session and each independently trips its thresholds, `self-report` files **one issue per skill** — never bundled. Different skills go to different fix surfaces.

After filing, the calling agent mentions it once at the end of the turn:

> I noticed friction in this run across `retirement-plan` and `weekly-review`. I've filed one issue per skill. [link, link]

## Labels

Every issue gets two labels:

- `skill-self-report` — the category label, applied to every self-report. Lets you see all friction reports across all skills.
- `skill:<skill-name>` — per-skill filter (e.g. `skill:retirement-plan`). The script auto-creates this label on first use with color `#c5def5`.

Filter the issues tab by either label depending on what you're looking for.

## Issue format

Body shape (per [`references/issue-format.md`](https://github.com/joestump/claude-skills/blob/main/self-report/references/issue-format.md)):

```markdown
## Trigger condition
<explicit invoke / project-name match / new doc / money event / staleness / etc.>

## Run summary
- Tool-call count: <n>
- Render attempts: <n>
- Phase reached: <discovery / gap / interview / render / self-eval / other>

## What happened
<1–3 concrete sentences. Symptom-first. No speculation.>

## Failure signals
- [x/-] tool-call budget exceeded
- [x/-] same bug retried more than twice
- [x/-] more than 3 material assumptions
- [x/-] render integrity (literal `${...}`, NaN/undefined, missing tabs, broken close tag)
- [x/-] design-spec regression
- [x/-] user pushback in same turn
- [x/-] other: <free-text>

## Suggested fix
<which file in the calling skill should change>

## Run context (sanitized)
- Model
- Surface (Claude.ai web / Claude Code / API)
- Trigger source
```

## Privacy

Issue bodies are public. The skill applies a strict filter [before](https://github.com/joestump/claude-skills/blob/main/self-report/references/privacy.md) writing:

- **Never:** user/partner/child/employer names, account balances, net-worth, income, debt, addresses, document filenames containing identifiers, direct quotes from user docs, dollar amounts of any kind, percentages of the user's portfolio, health/relationship details, LLC/trust/entity names.
- **OK:** generic skill behaviors that misfired, tool-call counts, names of files in this skills repo, knob/feature names, model + surface.

When in doubt, drop the detail. A vaguer issue is fine; a leak is not.

## Filing path (tier chain)

The skill walks the chain in order until one succeeds:

1. **GitHub MCP** — if available, file directly via the MCP tool.
2. **`gh` CLI** — call [`scripts/file_issue.sh`](https://github.com/joestump/claude-skills/blob/main/self-report/scripts/file_issue.sh) once per skill:

   ```sh
   ./file_issue.sh <skill-name> "<title>" <body-file>
   ```

   The script ensures `skill:<name>` exists, then creates the issue with both labels.
3. **Fallback** — write the body to `$SKILL_ISSUE_OUT_DIR/skill-issue-<skill-name>.md` (default `/mnt/user-data/outputs/`) and print a prefilled `https://github.com/joestump/claude-skills/issues/new?labels=...&title=...` URL.

On the fallback path only, the calling agent mentions the report **once per session**:

> I noticed friction in this run. I've written self-reports to `skill-issue-*.md` — paste them as new issues at https://github.com/joestump/claude-skills/issues/new if you'd like to track them.

## Arguments

The shell script takes three positional arguments:

```sh
file_issue.sh <skill-name> <title> <body-file>
```

| Arg | Description |
|---|---|
| `skill-name` | Directory name of the calling skill (`retirement-plan`, `self-report`, etc.). Drives the `skill:<name>` label. |
| `title` | Issue title. Convention: `[<skill-name>] <short symptom-first summary>`. |
| `body-file` | Path to a Markdown file containing the body. The script reads it via `--body-file`. |

Environment overrides:

- `SKILL_ISSUE_OUT_DIR` — fallback output directory. Default `/mnt/user-data/outputs/`.
