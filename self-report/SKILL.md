---
name: self-report
description: File GitHub issues against joestump/claude-skills when another skill in this repo hits friction during a run. Other skills in this repo delegate their self-evaluation reporting to this skill rather than implementing their own filing logic. Triggers when another skill explicitly invokes self-report after detecting that its trip thresholds were exceeded (tool-call budget, repeated bug retries, material assumptions, render integrity issues, user pushback in same turn), or when the user explicitly invokes /self-report. If multiple skills from this repo ran in the same session and each independently tripped, file one issue per skill — never bundle reports for different skills into a single issue. Each issue is labeled with both skill-self-report and skill:<skill-name> so they can be filtered per-skill on the issues tab. Issue bodies must never contain user data, account balances, names, or document contents — only meta-signals about how the run went.
---

# self-report

This skill is the single owner of "skill hit friction → file a GitHub issue." Other skills in this repo do not implement their own filing logic. They detect their own trip conditions, then hand off to `self-report` with a skill name, a short title, and a body.

## When to run

- Another skill in this repo signals that its run tripped one or more thresholds defined in that skill's own `references/self-eval.md`. Common signals (each skill defines its own exact thresholds):
  - Tool-call budget exceeded for the run mode
  - Same bug retried more than twice
  - More than 3 material assumptions during the run
  - Render-integrity failures (literal `${...}`, `NaN`/`undefined` in output, missing tabs, etc.)
  - User pushback in the same turn ("wrong", "ugly", "broken", "fix this")
- The user explicitly invokes `/self-report`.

**Do not self-report this skill.** If `self-report` itself fails, surface the failure to the user in chat. Filing-about-filing is a recursion trap.

## Multi-skill runs

If two or more skills from this repo ran in the same session and each independently tripped, file **one issue per skill**. Never bundle reports for different skills into a single issue — they go to different audiences (the maintainer of each skill) and have different fix surfaces.

When multiple issues are filed in one session, mention this to the user once at the end:

> I noticed friction in this run across `retirement-plan` and `weekly-review`. I've filed one issue per skill. [link, link]

Don't repeat. Don't nag.

## Workflow

For each skill that tripped:

1. **Build the issue body** following [`references/issue-format.md`](references/issue-format.md). Lift the run-specific facts (tool-call count, retry count, phase reached, failure-signal checkboxes) from the calling skill's run state.
2. **Sanitize.** Apply [`references/privacy.md`](references/privacy.md) before writing the body — no balances, names, document contents, addresses, partner identifiers, or direct quotes from user docs.
3. **File** via the path that's available (in order):
   1. **GitHub MCP**, if available. Repo: `joestump/claude-skills`. Labels: `skill-self-report` and `skill:<skill-name>`. Title: `[<skill-name>] <short summary>`.
   2. **`gh` CLI** via [`scripts/file_issue.sh`](scripts/file_issue.sh) — call it once per skill: `file_issue.sh <skill-name> "<title>" <body-file>`. The script ensures the per-skill label exists, then files.
   3. **Fallback**: the script writes the body to `$SKILL_ISSUE_OUT_DIR/skill-issue-<skill-name>.md` (default `/mnt/user-data/outputs/`) and prints a prefilled `https://github.com/joestump/claude-skills/issues/new` URL with `labels=skill-self-report,skill:<skill-name>&title=...` query params.
4. **Mention to the user once per session**, only on the fallback path:

   > I noticed friction in this run. I've written self-reports to `skill-issue-*.md` — paste them as new issues at https://github.com/joestump/claude-skills/issues/new if you'd like to track them.

## Labels

- `skill-self-report` — applied to every issue this skill files. Already exists on the repo.
- `skill:<skill-name>` — per-skill filter. The script auto-creates this label on first use with color `#c5def5`. Examples: `skill:retirement-plan`, `skill:weekly-review`.

## Things to never do

- Never include user financial data, account balances, names, document contents, addresses, partner names, or direct quotes from user documents in an issue body.
- Never bundle reports for multiple skills into a single issue.
- Never file an issue for a clean run.
- Never bring up the self-report more than once per session to the user.
- Never self-report this skill.
