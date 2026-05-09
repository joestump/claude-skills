# Privacy

Issue bodies are meta-signals about how a run went. They are public — assume strangers will read them on the issues tab. Apply this filter **before** writing the body, not after.

## Never include

- User's name, partner's name, child's name, employer name
- Account balances, net-worth figures, income figures, debt figures
- Property addresses, county names, city names if combined with other identifiers
- Document filenames that include user identifiers (e.g. `Smith_2026_W2.pdf`)
- Direct quotes from any user document
- Specific dollar amounts of any kind from the user's data
- Specific percentages of the user's portfolio or income
- Health, mental-health, or relationship details
- Any LLC, trust, or entity name

## OK to include

- Generic skill behaviors that misfired ("the projection table rendered with negative net worth in year 3")
- Tool-call counts, retry counts, phase reached
- Names of files in this skills repo (`SKILL.md`, `design-spec.md`, `retirement-plan-template.html`)
- Names of references, knobs, or features as defined in the skill (e.g. "the `--muted` variable", "the consulting-end-age knob")
- Model name and surface (Claude.ai web / Claude Code / API)

## When in doubt, drop it

If a detail makes the report more useful but you're not 100% sure it's safe, drop it. A vaguer issue is fine. An issue that leaks user data is not.

## Sanitization examples

| Don't write | Do write |
|---|---|
| "User has $1.4M at Vanguard and the chart cut Vanguard off" | "Chart axis upper bound was below max portfolio value, clipping the line" |
| "The Smith family's second-home year is 2032" | "Second-home year knob defaulted incorrectly" |
| "Wife can't clean Airbnbs anymore so we encoded it" | "Encoded a partner work-cessation milestone — verify default age is correct" |
| "Owner_Statement_2025-10.pdf was misclassified as bank" | "An Owner_Statement* file was misclassified — sniff rule needs tightening" |

## Filenames in fallback path

When the script writes `skill-issue-<skill-name>.md` to the outputs directory, that file is local to the user's machine. Privacy rules still apply — they may copy-paste it as-is.
