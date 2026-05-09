# Data checklist

Categorize every project file before asking the user anything. Use filename patterns first, then sniff content for ambiguous names.

## The 12 categories

1. **Brokerage statements** — taxable investment accounts.
2. **Retirement accounts** — 401(k), Traditional IRA, Roth IRA, HSA, pension statements.
3. **RSU / equity comp** — vest schedules, grant docs, ESPP enrollments.
4. **Crypto** — exchange statements, wallet exports, on-chain reports.
5. **Bank statements (personal)** — checking / savings.
6. **Bank statements (LLC / business)** — entity accounts.
7. **Mortgage / 1098** — primary residence and any rentals.
8. **Property tax / appraisal** — county tax bills, recent appraisals or comps.
9. **Rental income / owner statements** — property-management reports, Airbnb / VRBO summaries.
10. **Social Security estimates** — `my Social Security` PDFs for the user and spouse.
11. **Existing `retirement-plan.html`** — prior artifact. Parse the embedded `STATE` block as canonical.
12. **User spreadsheets / lifestyle earnings** — net-worth trackers, side-income summaries, custom budgets.

## Deceptive filename patterns — flag these explicitly

| Pattern | Actually is |
|---|---|
| `dxweb*.pdf` | Bank statement (personal or LLC — sniff the account header). |
| `BL1*`, `BL2*` | LLC bank statements (Bair's Lair I and II). Treat as **business** bank statements. |
| `Owner_Statement*` | Property-management report → **rental income**. |
| `Monthly_Statement*` | Could be brokerage, bank, or rental. **Always** sniff content before categorizing. |
| `1099-*`, `W-2*` | Tax docs — useful for income reality even if not in the 12 categories. |
| `1098*` | Mortgage interest → category 7. |

## Recency rules

| Category | Acceptable age | Stale threshold (warn but don't block) |
|---|---|---|
| Brokerage | < 6 months | ≥ 6 months |
| Retirement accounts | < 6 months | ≥ 6 months |
| RSU / equity | Current schedule | Prior calendar year |
| Crypto | < 3 months | ≥ 3 months |
| Bank statements | 12-month trailing window ideal, 6 months minimum | < 6 months coverage |
| Mortgage / 1098 | Current year | Prior year |
| Property tax / appraisal | Current tax year | > 24 months old |
| Rental income / owner statements | Trailing 12 months | < 6 months coverage |
| SS estimates | < 12 months | ≥ 12 months |
| Existing artifact | < 3 months | ≥ 3 months → re-trigger |
| User spreadsheets | < 3 months | ≥ 3 months |
| Lifestyle earnings | < 6 months | ≥ 6 months |

Stale docs render in the artifact with a warning callout. Missing critical inputs (income, assets, target retirement year) prompt an interview question; missing nice-to-haves are absorbed into reasonable defaults.

## Categorization output

For each file, record:

- Path
- Category (one of the 12, or `OTHER`)
- Period covered (e.g. `2026-01` — `2026-03`)
- Status: `HAVE` / `HAVE-STALE` / (`MISSING` is per-category, not per-file)
- One-line summary of useful values (account total, income figure, balance) — for your own use during the build, **never** in self-report issues.
