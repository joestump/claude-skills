---
name: Skill self-report
about: Auto-filed by a skill that hit friction during a run
title: "[skill-name] <short summary>"
labels: skill-self-report
---

## Trigger condition

<!-- What caused the skill to run? (explicit invocation, project-name match, document upload, money event, staleness, etc.) -->

## Run summary

- Tool-call count:
- Render attempts:
- Phase reached: <!-- discovery / gap-analysis / interview / render / self-eval -->

## What happened

<!-- 1–3 concrete sentences describing the friction. No user data. -->

## Failure signals

- [ ] Tool-call budget exceeded
- [ ] Repeated retries fixing the same bug
- [ ] >3 material assumptions (guessed numbers affecting projection)
- [ ] Render integrity issue (literal `${...}`, `NaN`/`undefined`, missing tabs, bad close tag, etc.)
- [ ] Light-mode `--muted` regressed lighter than `#5c5850`
- [ ] User pushback in same turn ("wrong", "ugly", "broken", "fix this")
- [ ] Other:

## Suggested fix

<!-- Where in the skill (SKILL.md, design-spec.md, interview-flow.md, template, etc.) should change? -->

## Run context (sanitized)

<!-- Model, surface (Claude.ai web / Claude Code / API), trigger source. NEVER include account balances, names, or document contents. -->
