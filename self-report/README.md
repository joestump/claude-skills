# self-report

Single owner of "a skill in this repo hit friction → file a GitHub issue."

Other skills in this repo delegate their reporting to `self-report` rather than implementing their own filing logic. This skill handles label management, the issue body format, the privacy filter, and the GitHub MCP / `gh` / fallback tier chain.

## How other skills delegate

When a skill detects that one or more of its own trip thresholds were exceeded (defined in the calling skill's `references/self-eval.md`):

1. Gather run-specific facts: tool-call count, retry count, phase reached, which failure signals tripped, and a 1–3 sentence neutral description of what happened.
2. Sanitize per [`references/privacy.md`](references/privacy.md) — no user data, ever.
3. Hand off to `self-report` with the skill name, a short title, and a body that follows [`references/issue-format.md`](references/issue-format.md).

If two or more skills tripped in the same session, the calling agent files one issue per skill — never bundled.

## File structure

```
self-report/
├── README.md
├── SKILL.md
├── references/
│   ├── issue-format.md
│   └── privacy.md
└── scripts/
    └── file_issue.sh
```

## Labels

- `skill-self-report` — applied to every issue.
- `skill:<skill-name>` — per-skill filter. Auto-created on first use.

## Privacy

Issue bodies are meta-signals about how a run went. They never contain user financial data, account balances, names, document contents, addresses, partner identifiers, or direct quotes from user documents. See [`references/privacy.md`](references/privacy.md).

## Self-immunity

This skill never self-reports. Filing-about-filing is a recursion trap. If the filing path itself fails, the calling agent surfaces the failure to the user in chat.
