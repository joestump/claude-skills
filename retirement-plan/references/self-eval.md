# Self-evaluation

Run after every render. **Silent on clean runs** — no postmortem brag. File an issue only when something tripped, and mention it to the user **once per session**.

## Trip thresholds (any one → file an issue)

### Tool-call budget

- Fresh build: **> 30** tool calls.
- Update of existing artifact: **> 18** tool calls.
- Knob-only change: **> 8** tool calls.

### Code churn

- **> 2 retries** fixing the same bug (template-literal escaping, calculation errors, styling regressions, etc.).

### Material assumptions

- **> 3** cases of guessing at numbers that materially affect the projection (income, balances, return %, target spending). One or two reasonable defaults are fine; four+ means the interview was incomplete.

### Render integrity

Any of these in the rendered file:

- Literal `${...}` (unescaped template literal).
- `NaN`, `undefined`, `null`, or `Infinity` displayed in a money cell.
- Missing tabs that the user's data should have populated.
- Broken `<script>` close tag, mismatched div counts, malformed HTML.
- Money rows missing `tabular-nums`.
- Light-mode `--muted` regressed lighter than `#5c5850`.
- Generic `<title>` like "Document".

### User pushback in the same turn

- "this is wrong"
- "ugly"
- "broken"
- "fix this"

## Issue format

**Title:** `[retirement-plan] <short summary>`

**Body:**

```
## Trigger condition
<explicit invoke / project-name match / new doc / money event / staleness>

## Run summary
- Tool-call count: <n>
- Render attempts: <n>
- Phase reached: <discovery / gap / interview / render / self-eval>

## What happened
<1–3 concrete sentences>

## Failure signals
- [x/-] tool-call budget
- [x/-] retry count
- [x/-] material assumptions (>3)
- [x/-] render integrity
- [x/-] muted-color regression
- [x/-] user pushback in same turn

## Suggested fix
<which file in the skill should change: SKILL.md, design-spec.md, interview-flow.md, template, etc.>

## Run context (sanitized)
<model, surface, trigger source — NO user data>
```

## Privacy

The issue body **must never** contain:

- User's name or partner's name
- Account balances or net-worth figures
- Income figures
- Document filenames that include identifying info
- Property addresses
- Any direct quote from a user document

Only meta-signals about how the run went.

## Filing path

1. **GitHub MCP available** → file directly via MCP tool. Repo: `joestump/claude-skills`. Label: `skill-self-report`.
2. **`gh` CLI available** → run `scripts/file_issue.sh` which calls `gh issue create --repo joestump/claude-skills --label skill-self-report --body-file <path>`.
3. **Neither** → script writes body to `$SKILL_ISSUE_OUT_DIR/skill-issue.md` (default `/mnt/user-data/outputs/skill-issue.md`) and prints a prefilled URL with `labels=skill-self-report&title=...` query params.

## User-facing mention (fallback path only)

Once per session, in plain prose:

> I noticed friction in this run. I've written a self-report at `skill-issue.md` — paste it as a new issue at https://github.com/joestump/claude-skills/issues/new if you'd like to track it.

Don't repeat. Don't nag. Don't surface clean runs.
