# Issue format

Every issue this skill files follows the same shape. Lift run-specific facts from the calling skill's state — but **only meta-signals**, never user data (see [`privacy.md`](privacy.md)).

## Title

```
[<skill-name>] <short summary>
```

Examples:

- `[retirement-plan] template literal rendered as ${k.spend} in spending column`
- `[retirement-plan] interview ran 4+ material assumptions before render`
- `[weekly-review] tool-call budget hit 22 on update path`

Keep the summary under ~70 characters. Lead with the symptom, not the speculation.

## Labels

- `skill-self-report` (always)
- `skill:<skill-name>` (the calling skill's directory name)

## Body

```markdown
## Trigger condition
<explicit invoke / project-name match / new doc / money event / staleness / etc.>

## Run summary
- Tool-call count: <n>
- Render attempts: <n>
- Phase reached: <discovery / gap / interview / render / self-eval / other>

## What happened
<1–3 concrete sentences. Symptom-first. No speculation about root cause unless it is obvious.>

## Failure signals
- [x/-] tool-call budget exceeded
- [x/-] same bug retried more than twice
- [x/-] more than 3 material assumptions
- [x/-] render integrity (literal `${...}`, `NaN`/`undefined`, missing tabs, broken close tag, etc.)
- [x/-] design-spec regression (e.g. `--muted` lightened past spec, white-on-white)
- [x/-] user pushback in same turn ("wrong", "ugly", "broken", "fix this")
- [x/-] other: <free-text>

## Suggested fix
<Which file in the calling skill should change: SKILL.md, design-spec.md, interview-flow.md, template, etc. One line.>

## Run context (sanitized)
- Model: <e.g. claude-opus-4-7>
- Surface: <Claude.ai web / Claude Code / API>
- Trigger source: <user invoke / auto / re-trigger>
```

## Tone

- Symptom-first. "Spending column rendered `${k.spend}`" — not "the formatter is broken because…"
- Neutral. No apologies, no editorializing.
- One signal per checkbox. Use `[x]` for tripped, `[-]` for not tripped. Do not omit the row.

## What goes in "What happened"

Three concrete sentences max. Examples of acceptable phrasings:

- "Two retries on the year-by-year table before column widths settled. Both retries were template-literal escaping in the milestone strip."
- "Interview defaulted base spending, vacation budget, healthcare, and lifestyle creep without asking. User had not provided spending data and the prior artifact did not have a spending block."
- "Render produced literal `${k.retireAge}` in the score row because the value was inserted as a string before knob bindings ran."

What does **not** go in "What happened":

- Account balances, percentages of net worth, dollar figures of any kind from the user's data
- The user's name, partner's name, or property identifiers
- Document filenames that include user identifiers
- Direct quotes from any user document

When in doubt, drop the detail. The issue is meta-signal, not a postmortem with evidence.
