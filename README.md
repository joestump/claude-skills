# claude-skills

A personal collection of [Claude](https://claude.ai) skills by Joe Stump.

Skills are self-contained instruction packs that Claude loads on demand to handle a specific kind of task with a consistent process and aesthetic.

## Skills

| Skill | Trigger | What it does |
|-------|---------|--------------|
| [`gemini-mockup`](./gemini-mockup) | `/gemini-mockup` or when user asks for UI mockups | Generates high-fidelity UI mockup PNGs using Gemini's image model via LiteLLM. Reads visual identity from project `CLAUDE.md`, frames output in macOS Safari chrome, auto-detects and updates stale mockups. |
| [`refresh-miatrix-token`](./refresh-miatrix-token) | Miatrix re-downloading same shows, Prowlarr Miatrix indexer errors, `/refresh-miatrix-token` | Logs into Miatrix via browser automation, extracts the current API key, and updates Prowlarr's indexer config — fixes the "re-downloading" symptom from key rotation. |
| [`retirement-plan`](./retirement-plan) | Retirement-themed Claude Project, `/retirement-plan`, new financial documents, money events, or stale plan | Generates a high-fidelity, durable `retirement-plan.html` artifact from financial documents and lifestyle assumptions. |
| [`self-report`](./self-report) | Invoked by another skill in this repo when its run trips its own thresholds, or `/self-report` | Files GitHub issues against this repo with per-skill labels (`skill:<name>`). Single owner of the filing path so other skills don't reimplement it. |
| [`pr-sweep`](./pr-sweep) | "sweep my open PRs", "merge my ready PRs", "shepherd joestump-agent's PRs", `/pr-sweep` | Sweeps open PRs across GitHub + Gitea for a resolved user (`whoami`→`joestump-agent`/`joestump`, or `--username`). Pushes fixes and replies on PRs the acting account authored; merges green + approved PRs authored by a *different* account. Never self-merges, never closes. |

## Install

### Claude.ai (web / desktop)

1. Zip the skill directory (e.g. `retirement-plan/`).
2. Open Claude → Settings → Capabilities → Skills → Upload.
3. Drop in the zip.

### Claude Code

Drop the skill directory into `~/.claude/skills/`:

```sh
cp -r retirement-plan ~/.claude/skills/
```

Claude Code picks it up automatically on the next session.

## Repository structure

```
claude-skills/
├── .github/
│   └── ISSUE_TEMPLATE/
│       └── skill-self-report.md
├── LICENSE
├── README.md
├── gemini-mockup/
│   ├── SKILL.md
│   ├── references/
│   │   ├── browser-chrome.md
│   │   └── quality-bar.md
│   └── scripts/
│       └── generate.sh
├── pr-sweep/
│   ├── SKILL.md
│   └── scripts/
│       └── list-open-prs.sh
├── refresh-miatrix-token/
│   └── SKILL.md
├── retirement-plan/
│   ├── README.md
│   ├── SKILL.md
│   ├── assets/
│   └── references/
└── self-report/
    ├── README.md
    ├── SKILL.md
    ├── references/
    └── scripts/
```

## Self-reporting

Skills here delegate to [`self-report`](./self-report) when a run hits friction — too many tool calls, repeated render bugs, material assumptions, or user pushback. It files an issue against this repo with `skill-self-report` plus a per-skill label (`skill:retirement-plan`, etc.) so you can filter the issues tab. If multiple skills tripped in one session, one issue per skill — never bundled.

Reports never include user data; they're meta-signals about how the run went, used to improve the skills over time.

## License

[MIT](./LICENSE) © 2026 Joe Stump.
