---
name: retirement-plan
description: Generate a high-fidelity, durable retirement-plan.html from a Claude Project's financial documents and lifestyle assumptions. Triggers when the project name suggests retirement focus (retire, retirement, FIRE, early retire, freedom), the user invokes /retirement-plan or asks to build/update/refresh the plan, new financial documents are uploaded, the user mentions a money event (inheritance, RSU vest, property sale, large bonus, paid-off mortgage), or an existing retirement-plan.html is older than 3 months OR built from documents older than 6 months. Produces a single self-contained HTML file with five tabs (Execution plan, Income reality, Big purchases, At retirement, Lifetime projection), inline SVG chart, and interactive knobs. Re-triggers read the prior artifact as canonical state and apply deltas rather than starting over.
---

# retirement-plan

You produce a single self-contained `retirement-plan.html` for the user. The artifact is the deliverable — durable, mobile-friendly, dark-mode aware, and re-openable months later without Claude.

## Triggers

Activate (silently — do **not** announce the skill) on any of:

- Project name contains `retire`, `retirement`, `FIRE`, `early retire`, or `freedom`.
- User invokes `/retirement-plan` or asks to build / update / refresh / regenerate the retirement plan.
- New financial documents are uploaded to a retirement project.
- User mentions a money event: inheritance, RSU vest, property sale, large bonus, paid-off mortgage, job change, divorce, etc.
- Existing `retirement-plan.html` in the project is older than **3 months** OR was built from documents older than **6 months**.

### Outside a Claude Project

If you're not in a Project, tell the user once:

> Retirement planning works far better in a Claude Project — files persist, assumptions accumulate across conversations, and past-conversation memory ties everything together. I'd recommend creating one. I can still build a plan from what you've shared in this chat, but it won't carry over.

Then proceed best-effort.

## Five-phase workflow

### 1. Discovery

- List every file in the project. Categorize each per [`references/data-checklist.md`](references/data-checklist.md). Sniff content for ambiguous names (`dxweb*.pdf`, `BL1*`, `BL2*`, `Owner_Statement*`, `Monthly_Statement*`).
- Search past conversations in this project for prior interview answers, money events, and lifestyle context.
- Read user memory at `~/.claude/projects/.../memory/` for relevant facts.
- If a prior `retirement-plan.html` exists, parse it. Its embedded `STATE` block is canonical. Preserve user-set knob values.

### 2. Gap analysis

For each of the 12 data categories, mark **HAVE** / **HAVE-STALE** / **MISSING** using the recency rules in [`references/data-checklist.md`](references/data-checklist.md). Stale documents render with a warning callout — they do not block the build.

### 3. Interview

Follow [`references/interview-flow.md`](references/interview-flow.md):

- Skip anything already known from documents, past conversations, memory, or prior artifact.
- ≤3 questions per turn. Mobile-friendly. Multiple-choice tools where available.
- Use industry terms (PIA, FRA, RMD, SWR) without defining them — assume finance literacy.
- **Never surface sensitive topics in fresh interviews**: partner health limits, life expectancy, anxiety/relationship stress. Encode known constraints into knob defaults silently.

### 4. Render

Build one self-contained HTML file using [`assets/retirement-plan-template.html`](assets/retirement-plan-template.html) as the structural skeleton, following [`references/design-spec.md`](references/design-spec.md) **exactly**. The design language is non-negotiable:

- Single file. Inline `<style>` and vanilla `<script>`. Google Fonts is the only external dependency.
- DM Sans (body/UI) + DM Serif Display (display headings). Tabular numbers on every money cell.
- The exact CSS-variable palette in `design-spec.md`, light + dark via `prefers-color-scheme`. **Light-mode `--muted` is `#5c5850` — never lighten it.** Cards are white on `#f5f3ed` cream — no white-on-white.
- Centered 720px wrap. Header with overline + serif `<h1>` + muted subtitle. Four-up score row. Tabs with accent underline. Tables with cream header rows, hairline separators, accent-tinted event rows, green-bg debt-free / retirement-flip rows.
- Money formatter from `design-spec.md`: ≥$1M → `$1.58M`; ≥$1K → `$15,060`; <$1K → `$650`; negatives parenthesized; null → em dash.
- Knobs split into two sub-tabs (Income & retirement timing / Spending & lifestyle).
- Inline SVG line chart. No charting library.
- Year-by-year projection table with milestone strips for Retire, partner-stops-cleaning (or equivalent), 59.5, Medicare-65, SS-claim, Spouse-SS, RMDs-73, pension drawdown.
- Column glossary after every data table.
- Bottom-line callout per headline tab (green if healthy, red if projection breaks).
- Footer ends with "Not financial advice."
- Skip tabs the data doesn't support. Don't invent new tabs.

Write the file where the user can download it (Claude.ai outputs path or working directory in Claude Code).

### 5. Self-evaluation

Run [`references/self-eval.md`](references/self-eval.md) to determine whether this run tripped any thresholds. On a clean run: silent. On friction: delegate to the [`self-report`](../self-report/SKILL.md) skill — pass skill name `retirement-plan`, a short title, and a body following self-report's issue format. Mention it to the user **once per session** on the fallback path only. Don't nag, don't announce clean runs.

Filing logic, label management, privacy filter, and the GitHub MCP / `gh` / fallback tier chain all live in `self-report`. This skill only decides *whether* to file and *what* the body says — not *how* to file.

## Re-trigger semantics

A re-trigger does **not** rebuild from scratch. Read the prior `retirement-plan.html` → treat its embedded `STATE` block as canonical → apply the delta from new docs / events / answers → re-render. Preserve user-set knob values unless they become invalid (e.g. retirement age < current age).

## Things to never do

- Don't announce "I'm using the retirement-plan skill." Just do the work.
- Don't ask about sensitive topics (partner health, life expectancy, mental health). Encode constraints silently.
- Don't introduce CSS frameworks (no Bootstrap, no Tailwind), gradients, glassmorphism, neon, drop shadows beyond hairline borders, pie charts, emojis as visual elements, or title-case body copy.
- Don't lighten light-mode `--muted` past `#5c5850`. Don't put white on white.
- Don't invent new tabs. Don't include user financial data in self-report issues.
- Don't surface clean-run self-evaluation. Don't bring up the self-report more than once per session.
