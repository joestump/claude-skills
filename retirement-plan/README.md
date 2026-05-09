# retirement-plan

Generates a high-fidelity, durable `retirement-plan.html` artifact from a Claude Project's financial documents and lifestyle assumptions.

## What it produces

A single self-contained HTML file with five tabs:

1. **Execution plan** — the next 12–24 months of debt paydown, savings moves, and milestones.
2. **Income reality** — what's actually coming in today (W-2, RSUs, rentals, side income).
3. **Big purchases** — second home, vehicles, sabbaticals, anything large and dated.
4. **At retirement** — the snapshot at the user's target retirement year.
5. **Lifetime projection** — interactive year-by-year with knobs and an inline SVG chart.

Each tab ends in a green or red bottom-line callout. Every data table has a column glossary the user can re-read months later.

## When it triggers

- Project name suggests retirement focus (`retire`, `retirement`, `FIRE`, `early retire`, `freedom`). Auto-trigger silently.
- User invokes `/retirement-plan` or asks to build / update / refresh the plan.
- New financial documents uploaded.
- User mentions a money event (inheritance, RSU vest, property sale, large bonus, paid-off mortgage).
- Existing `retirement-plan.html` is older than 3 months OR built from documents older than 6 months.

Outside of a Claude Project, the skill recommends creating one (so files persist and assumptions accumulate) and proceeds best-effort with what's been shared.

## Five-phase workflow

1. **Discovery** — categorize project files per [`references/data-checklist.md`](./references/data-checklist.md), search past conversations, read user memory, parse any existing `retirement-plan.html` for canonical state.
2. **Gap analysis** — score each category as HAVE / HAVE-STALE / MISSING.
3. **Interview** — short, mobile-friendly, skipping anything already known. See [`references/interview-flow.md`](./references/interview-flow.md).
4. **Render** — single self-contained HTML file per [`references/design-spec.md`](./references/design-spec.md). Built on [`assets/retirement-plan-template.html`](./assets/retirement-plan-template.html).
5. **Self-evaluation** — run the checklist in [`references/self-eval.md`](./references/self-eval.md). Silent on clean runs. On friction, file a GitHub issue (label `skill-self-report`) via [`scripts/file_issue.sh`](./scripts/file_issue.sh).

Re-triggers don't start from scratch: the skill reads the prior `retirement-plan.html`, treats its embedded data block as canonical state, applies the delta, and re-renders. User-set knob values are preserved unless they become invalid.

## File structure

```
retirement-plan/
├── README.md
├── SKILL.md
├── assets/
│   └── retirement-plan-template.html
├── references/
│   ├── data-checklist.md
│   ├── design-spec.md
│   ├── interview-flow.md
│   └── self-eval.md
└── scripts/
    └── file_issue.sh
```

## Privacy

Self-report issues never include account balances, names, document contents, or any user financial data. They contain only meta-signals about how the run went (tool-call count, retry count, render-integrity flags).

## Disclaimer

Not financial advice. The artifact is a planning tool — projections are estimates based on the user's own inputs and assumptions, and the user should validate decisions with a licensed advisor.
