---
sidebar_position: 2
title: retirement-plan
---

# retirement-plan

Generates a high-fidelity, durable `retirement-plan.html` artifact from a Claude Project's financial documents and lifestyle assumptions. The output is a single self-contained HTML file you can re-open months later without Claude — knobs, charts, year-by-year projection, and column glossaries all bundled.

[**Source on GitHub →**](https://github.com/joestump/claude-skills/tree/main/retirement-plan)

## What you get

A single `.html` file with five tabs:

| Tab | What's in it |
|---|---|
| **Execution plan** | The next 12–24 months of debt paydown, savings moves, milestones. |
| **Income reality** | What's actually coming in today — W-2, RSUs, rentals, side income. |
| **Big purchases** | Second home, vehicles, sabbaticals, anything large and dated. |
| **At retirement** | Snapshot at your target retirement year. |
| **Lifetime projection** | Interactive year-by-year with knobs and an inline SVG chart. |

Each tab ends in a green or red bottom-line callout. Every data table has a column glossary you can re-read months later when you've forgotten what "PIA" means.

## How it triggers

The skill activates **silently** (it doesn't announce itself) on any of:

- A Claude Project name containing `retire`, `retirement`, `FIRE`, `early retire`, or `freedom`.
- You invoke `/retirement-plan` or ask to build / update / refresh / regenerate the plan.
- New financial documents are uploaded to the project.
- You mention a money event: inheritance, RSU vest, property sale, large bonus, paid-off mortgage, job change.
- An existing `retirement-plan.html` in the project is older than 3 months, **or** was built from documents older than 6 months.

### Outside a Claude Project

The skill will recommend creating one (so files persist and assumptions accumulate across conversations) and then proceed best-effort with what you've shared in the chat.

## Examples

### First-time build

> Create a Claude Project called "Retire by 50". Upload your last 6 months of brokerage and 401(k) statements, your most recent SS estimate PDF, and a current mortgage 1098. Open a chat and say:
>
> *"Let's start working on my retirement plan."*

The skill silently triggers, categorizes the docs per its data checklist, and begins a short interview to fill the gaps (target retirement year, base spending, vacation budget, SS claim ages). Output: `retirement-plan.html`.

### Update on a money event

> *"My company just announced a $200K retention bonus vesting next quarter. Update the plan."*

Re-trigger reads the prior `retirement-plan.html` as canonical state, applies the delta (extra income event in the projection), preserves your knob settings, and re-renders.

### Knob-only tweak

> *"What if I retire at 52 instead of 50?"*

A small, fast pass — only the lifetime projection tab and headline scores recompute. No interview.

## Arguments / knobs

The Lifetime projection tab exposes two sub-tabs of knobs you can tweak directly in the HTML.

### Income & retirement timing

- Retirement age
- Consulting days/yr
- Consulting end age
- His SS claim age
- Spouse SS claim age
- Real return % (default 5%)
- Real RE appreciation % (default 1%)
- Inflation % (default 3%)
- Pension drawdown start age
- Property sale years (e.g. `2032,2038`)

### Spending & lifestyle

- Base annual spending
- Healthcare cost / yr (escalates with age)
- Vacation budget / yr
- Car replacement every N years × $X (default 8 years × $40K)
- Second home year + cost
- Annual lifestyle creep % (default 1.5%)
- Market crash modeling (default every 10 years, drop 25%)

The skill encodes some constraints **silently** based on past-conversation context — for example, a "partner stops working" milestone if you've previously mentioned that constraint. It will not surface those topics in fresh interviews.

## Re-trigger semantics

Re-triggers do **not** rebuild from scratch. The skill reads the prior `retirement-plan.html`, treats its embedded `STATE` block as canonical, applies the delta, and re-renders. Your knob values are preserved unless they become invalid (e.g. retirement age earlier than current age).

## What it won't do

- Surface partner health limits, life expectancy, anxiety, or relationship stress in interviews. The artifact is finance, not therapy.
- Use a CSS framework or charting library. The output is a single self-contained HTML file with inline `<style>` and vanilla `<script>`.
- Render emojis, gradients, glassmorphism, drop shadows, or pie charts. The aesthetic is a non-negotiable design language ([see the spec](https://github.com/joestump/claude-skills/blob/main/retirement-plan/references/design-spec.md)).

## Disclaimer

Not financial advice. The artifact is a planning tool — projections are estimates based on the inputs you provide and the assumptions encoded in the knobs. Validate decisions with a licensed advisor.
