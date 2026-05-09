# Self-evaluation

Run after every render. **Silent on clean runs** — no postmortem brag.

If any threshold below tripped, delegate to the [`self-report`](../../self-report/SKILL.md) skill. Pass:

- `skill-name`: `retirement-plan`
- `title`: `[retirement-plan] <short symptom-first summary>`
- `body`: built per [`self-report/references/issue-format.md`](../../self-report/references/issue-format.md), sanitized per [`self-report/references/privacy.md`](../../self-report/references/privacy.md)

The `self-report` skill handles labels, the filing tier chain (GitHub MCP → `gh` → fallback), and the once-per-session user mention.

## Trip thresholds (any one → file)

### Tool-call budget

- Fresh build: **> 30** tool calls.
- Update of existing artifact: **> 18** tool calls.
- Knob-only change: **> 8** tool calls.

### Code churn

- **> 2 retries** fixing the same bug (template-literal escaping, calculation errors, styling regressions).

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
