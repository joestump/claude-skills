---
sidebar_position: 1
title: gemini-mockup
---

# gemini-mockup

Generate production-quality UI mockup screenshots using Google's Gemini image model through LiteLLM. The skill reads your project's visual identity from `CLAUDE.md`, frames the output in macOS Safari chrome with your project URL, and automatically detects when existing mockups are out of date.

[**Source on GitHub →**](https://github.com/joestump/claude-skills/tree/main/gemini-mockup)

## What you get

High-fidelity PNG mockups that:

- **Match your visual identity** — colors, typography, components, icons read from your `CLAUDE.md`
- **Look real** — framed in browser chrome (macOS Safari) with your project's domain
- **Stay organized** — saved to stable filenames so regenerating updates in-place
- **Auto-detect staleness** — flags older mockups when visual identity changes

Output is a PNG file ready to paste into design docs, specs, or presentations.

## When to use

Trigger this skill when:

- The user asks to "mock up", "generate a mockup", "update the design", or "show me the UI" for any screen or component
- A UX spec lands and you need to visualize the screens
- Visual identity changes (theme, colors, framework) and old mockups need refreshing

**Don't use** for ASCII wireframes, backend specs, or when the user wants hand-drawn sketches.

## How it works

1. **Reads your visual identity** from the project's `CLAUDE.md` (color palette, typography, component framework, icons)
2. **Resolves the output path** — either from your explicit path or auto-generates one in `docs/openspec/specs/<capability>/mockups/`
3. **Scans for stale mockups** — flags existing screenshots that may need updating
4. **Constructs the prompt** — combines browser framing + visual identity + screen description
5. **Calls Gemini** via LiteLLM and saves the PNG

## Setup

### Prerequisites

- `OPENAI_BASE_URL` and `OPENAI_API_KEY` environment variables (LiteLLM gateway)
- A project `CLAUDE.md` with a `## Visual Identity` section (optional but recommended)

### Installation

```sh
cp -r gemini-mockup ~/.claude/skills/
```

Claude Code picks it up automatically on the next session.

## Examples

### First mockup

> You're designing a login flow. Your `CLAUDE.md` has:
>
> ```
> ## Visual Identity
> - Framework: Tailwind + shadcn/ui
> - Palette: cool grays, accent blue (#3B82F6)
> - Typography: Inter (system fonts fallback)
> - Icons: Lucide
> ```
>
> You ask: *"Mock up a login screen with email, password, and 'Remember me' checkbox."*

The skill reads your visual identity, calls Gemini, and saves `01-login.png` to your project. Opens it automatically.

### Regenerate on visual identity change

> Your `CLAUDE.md` updated: theme switched from cool grays to warm earthy tones.
>
> You ask: *"The visual identity changed — regenerate the mockups."*

The skill detects the change, flags the old `01-login.png` as potentially stale, and regenerates it with the new palette.

### Custom path

> You ask: *"Mock up the admin dashboard at `docs/mockups/admin-dashboard.png`."*

The skill uses that exact path and overwrites the file if it exists.

## Visual Identity in CLAUDE.md

To use this skill, add a section to your project's `CLAUDE.md`:

```markdown
## Visual Identity

- **Framework**: Tailwind + shadcn/ui (or DaisyUI, custom, etc.)
- **Color Palette**: Primary blue (#3B82F6), accent orange, neutral grays
- **Typography**: Inter for headings, system font for body
- **Icons**: Lucide (or Hero Icons, Phosphor, etc.)
- **Aesthetic**: Minimal, modern, clean lines. Emphasize whitespace.
- **Domain**: `app.example.com` (used in browser chrome framing)
```

If your project doesn't have this section, the skill will ask if you want to draft one or supply it inline for that mockup only.

## Tips

- **Stable filenames**: Use descriptive names like `01-login.png` or `dashboard.png`, not timestamps
- **Organize by spec**: Store mockups in `docs/openspec/specs/<capability>/mockups/` alongside requirements
- **Update visual identity once**: Changing `CLAUDE.md` once affects all future mockups — no per-mockup tweaking needed
- **Regenerate regularly**: When design goals shift, just re-ask and the skill regenerates with fresh style

## Limitations

- **Gemini image model latency**: First call takes ~10–15 seconds
- **No interactive UI**: Mockups are static PNGs, not clickable prototypes
- **Browser chrome only**: Frames in Safari; if you need mobile or other browsers, mention it in the description

## Troubleshooting

**"Visual Identity section not found"**

Ensure your `CLAUDE.md` has a `## Visual Identity` section (or `## Style Guide`, `## Mockup Style`). If it doesn't exist, the skill will ask if you want to draft one.

**"LiteLLM not configured"**

Set `OPENAI_BASE_URL` and `OPENAI_API_KEY` in your shell environment. The skill loads them automatically.

**"Mockup doesn't match my vision"**

Refine the visual identity in `CLAUDE.md` or provide more detailed description in the screen spec. Regenerate and the mockup will improve.
