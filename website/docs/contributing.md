---
sidebar_position: 99
title: Contributing
---

# Contributing

This is a personal skills mono-repo. PRs are welcome but the bar is "does this fit my workflow", not "is this generally useful."

## Repo layout

```
claude-skills/
├── .github/
│   └── workflows/
│       ├── release-skill.yml      # zips a skill on tag push
│       └── deploy-website.yml     # deploys this site to GitHub Pages
├── retirement-plan/               # one skill
├── self-report/                   # one skill
├── website/                       # this Docusaurus site
└── README.md
```

Every skill is a top-level directory with at minimum:

- `SKILL.md` — frontmatter + instructions Claude follows when triggered.
- `README.md` — human-readable overview.

Optional but encouraged:

- `references/` — phase-specific docs Claude pulls in (interview flow, design spec, self-eval thresholds).
- `assets/` — templates, fixtures.
- `scripts/` — shell scripts the skill shells out to.

## Versioning

Per-skill tags only:

```
<skill-name>-v<MAJOR>.<MINOR>.<PATCH>
```

Don't use a global `v*` tag — skills version independently. Pushing a matching tag triggers `release-skill.yml`, which zips the skill and attaches it to a GitHub Release.

Cut a release:

```sh
git tag retirement-plan-v1.2.0
git push origin retirement-plan-v1.2.0
```

## Self-evaluation

Every skill should define its own trip thresholds in `references/self-eval.md` (tool-call budget, retry count, render integrity, user pushback). On a trip, skills delegate to [`self-report`](./self-report) — they don't reimplement filing logic.

## The website

The site you're reading lives in `website/`. It deploys to GitHub Pages on every push to `main` via `.github/workflows/deploy-website.yml`.

To run locally:

```sh
cd website
npm install
npm run start
```

Adding a new skill? Edit:

- `website/src/components/SkillTiles/index.js` — add a tile.
- `website/sidebars.js` — add a doc entry.
- `website/docs/<skill-name>.md` — write the guide.
