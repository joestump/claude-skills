# claude-skills

A personal collection of [Claude](https://claude.ai) skills by Joe Stump.

Skills are self-contained instruction packs that Claude loads on demand to handle a specific kind of task with a consistent process and aesthetic.

## Skills

| Skill | Trigger | What it does |
|-------|---------|--------------|
| [`retirement-plan`](./retirement-plan) | Retirement-themed Claude Project, `/retirement-plan`, new financial documents, money events, or stale plan | Generates a high-fidelity, durable `retirement-plan.html` artifact from financial documents and lifestyle assumptions. |

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
└── retirement-plan/
    ├── README.md
    ├── SKILL.md
    ├── assets/
    ├── references/
    └── scripts/
```

## Self-reporting

Several skills here will file a GitHub issue against this repo (label: `skill-self-report`) when a run hits friction — too many tool calls, repeated render bugs, material assumptions, or user pushback. These reports never include user data; they're meta-signals about how the run went, used to improve the skills over time.

## License

[MIT](./LICENSE) © 2026 Joe Stump.
