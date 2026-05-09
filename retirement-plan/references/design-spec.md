# Design spec

The aesthetic of `retirement-plan.html` is non-negotiable. It has been iterated on heavily. Don't drift.

## Output format

- **Single self-contained HTML file.** Inline `<style>` and vanilla `<script>`. Output to a path the user can download.
- **No frameworks.** No React. No bundlers. No Bootstrap. No Tailwind via CDN.
- **Only external dependency**: Google Fonts.
- Document `<title>` is specific (e.g. `Retire by 50 — May 2026`). Never generic ("Document", "Retirement Plan").

## Typography

- Body and UI: `'DM Sans', sans-serif`, weights 400 / 500 / 600.
- Display headings: `'DM Serif Display', serif`, weight 400.
- Tabular numbers (`font-variant-numeric: tabular-nums`) on **every** money cell — table cells, score values, callout numbers.
- Don't reach for other fonts.

## Palette (use these exact CSS variables)

```css
:root{
  --ink:#1a1915;--warm:#2c2921;--muted:#5c5850;--faint:#7a756b;
  --bg:#f5f3ed;--card:#ffffff;--cream:#edeae2;
  --accent:#b45309;--accent-light:#fef3c7;
  --green:#166534;--green-bg:#dcfce7;
  --red:#991b1b;--red-bg:#fee2e2;
  --blue:#1e40af;--blue-bg:#dbeafe;
  --brd:#d9d4c9;--brd-h:#c4bfb4;
}
@media(prefers-color-scheme:dark){:root{
  --ink:#e7e5e4;--warm:#d6d3d1;--muted:#a8a29e;--faint:#78716c;
  --bg:#1c1917;--card:#292524;--cream:#292524;
  --accent:#f59e0b;--accent-light:#451a03;
  --green:#4ade80;--green-bg:#14532d;
  --red:#fca5a5;--red-bg:rgba(153,27,27,.25);
  --blue:#93c5fd;--blue-bg:#1e3a5f;
  --brd:#44403c;--brd-h:#57534e;
}}
```

### Contrast rule (do not regress)

- Light-mode `--muted` is `#5c5850`. **Never** lighten it. The user has caught earlier `#8a847a` for being unreadable on white.
- Light-mode `--bg` is `#f5f3ed` (warm cream) with white cards on top. **Never** put white on white.

## Layout

- `.wrap{max-width:720px;margin:0 auto;padding:32px 36px}`. Centered with side margins is non-negotiable.
- Mobile (`@media(max-width:640px)`):
  - `.scores` → `grid-template-columns:1fr 1fr`
  - `.tbl` → `70px 1fr 80px 80px 90px` columns
  - `.knobs` → `1fr`
  - `.tri-grid` → `1fr`

## Header block

- Small uppercase overline: `LAST UPDATED <date>`.
- Serif `<h1>` — the framing the user prefers ("Retire by 50", "Work optional at 52", etc.).
- One-line subtitle in `--muted`: `Age 46 · Target Mar 2030 · $125–150K/yr`.

## Score row (four-up)

- Four cards: net worth · debt-free by · big-purchase ready · retirement income (or appropriate substitutes).
- Card: `--card` background, 1px `--brd`, 4px radius, 16px padding, label in `--muted` 11px uppercase, value in `--ink` 22px tabular-nums.

## Tabs

- Border-bottom 1px `--brd`. Accent underline (2px `--accent`) on active.
- Fade-up animation (8px translate, 180ms) on panel switch.
- **Order:** Execution plan → Income reality → Big purchases → At retirement → Lifetime projection.
- Skip tabs the user's data doesn't support. Don't invent new tabs without precedent.

## Tables

- Header row: `--cream` background, uppercase 11px label text, `--muted` color.
- Data rows: `--card` background, hairline (`.5px`) bottom borders.
- Numbers right-aligned, 13px tabular-nums.
- Event rows tinted `--accent-light`.
- Debt-free / retirement-flip rows: `--green-bg`.
- Click-to-expand on event rows (toggles a sub-row of context).

## Money formatting

```js
const fmt = n => {
  if (n == null) return "—";
  const neg = n < 0, abs = Math.abs(n);
  const s = abs >= 1e6 ? `$${(abs/1e6).toFixed(2)}M`
          : abs >= 1e3 ? `$${Math.round(abs).toLocaleString()}`
          : `$${Math.round(abs)}`;
  return neg ? `(${s})` : s;
};
```

- ≥ $1M: `$1.58M`
- ≥ $1K: `$15,060`
- < $1K: `$650`
- Negative: parenthesized accounting style — `($1,234)`
- Null / unknown: em dash `—`

## Knobs (Lifetime projection tab)

Two sub-tabs:

**Income & retirement timing**
- Retirement age
- Consulting days/yr
- Consulting end age
- His SS claim age
- Spouse SS claim age (if applicable)
- Real return %
- Real RE appreciation %
- Inflation %
- Pension drawdown start age
- Property sale years

**Spending & lifestyle**
- Base annual spending
- Healthcare cost / yr (escalates with age)
- Vacation budget / yr
- Car replacement every N years × $X
- Second home purchase year + cost
- Annual lifestyle creep %
- Market crash modeling (every N years drop X%)

**Knob row style:** label left (12px `--muted`), control right. Control is a `<select>` or `<input type="number">`, 13px, `padding:6px 10px`, 1px `--brd`, 4px radius, `--card` background.

## Chart (Lifetime projection)

- Inline SVG line chart. **No charting library.**
- Plot total portfolio + total real estate + total net worth from retirement year to age 95.
- Optional red dots on crash years.
- ~640 × 220.
- Axis labels in `--muted`. Gridlines `0.5px var(--brd)`.

## Year-by-year projection table

- Columns: `Year | Age | Income | Spending | Net | Net worth`.
- Milestone strip below the matching year's row in `--accent`:
  - Retire
  - Wife-stops-cleaning (or equivalent partner constraint, encoded silently)
  - IRA-penalty-free-59.5
  - Medicare-65
  - SS-claim
  - Spouse-SS
  - RMDs-73
  - Pension drawdown

## Column glossary (`.glossary`)

After every data table:

- `--cream` background block.
- `.glossary-row` grid: `140px 1fr` (term + definition).
- Border-top hairline.
- The user reviews the artifact months later and needs a refresher. **Always include the glossary.**

## Bottom-line callout

- Ends each headline tab.
- Green-bg if healthy, red-bg if projection breaks.
- One-line verdict, then 2–3 sentences.

## Footer

- 11px `--faint`. Top border 1px `--brd`. Top margin 32px.
- Always ends with: `Not financial advice.`

## Things to avoid

- SaaS gradients, neon, glassmorphism.
- Drop shadows beyond hairline borders.
- CSS frameworks via CDN.
- Emojis as visual elements (a single ✓ or ⚠ in a callout is fine).
- Pie charts. Bars and lines only.
- Centered numbers in cells. Money is always right-aligned.
- Title case in body copy. Sentence case: "Income reality", not "Income Reality".
- Bullet-list dumps in place of tables.
