---
name: gemini-mockup
description: Generate high-fidelity UI mockup PNGs for any project by calling Gemini's image model through LiteLLM. Use this whenever the user asks to mock up, generate, regenerate, or update a UI screen, page, modal, or component — login screens, dashboards, settings panels, wizards, admin views, anything with a visual surface. The skill reads the project's visual identity from its `CLAUDE.md` at runtime, frames every output in macOS Safari chrome with a project-appropriate URL, saves to a stable filename so reruns overwrite cleanly, and scans in arrears for older mockups in the same directory that may be stylistically out of date. Prefer this over the bundled `mockup-generator` skill when LiteLLM is the gateway (env vars `OPENAI_BASE_URL` and `OPENAI_API_KEY` live in the user's login shell) and when project visual identity should drive style rather than light-mode DaisyUI defaults.
---

# gemini-mockup

Generate production-quality UI mockup screenshots by calling Gemini's image model
(`gemini-3-pro-image-preview`) through LiteLLM. The skill is project-agnostic:
each project supplies its own visual identity via its `CLAUDE.md`. The skill
handles env loading, browser-chrome framing, the API call, and lifecycle
discipline (stable filenames, scan-in-arrears, image opening).

## When to use

Trigger this skill whenever:

- The user asks to "mock up", "generate a mockup", "make a mockup of", "show me
  the UI", "regenerate the screenshot", "update the design" for a screen,
  page, modal, panel, or component.
- A new spec lands that covers UX or frontend surfaces, and you need to
  visualize how the screens look.
- A visual-identity decision changed (theme, color palette, framework,
  typography) and existing mockups need to be regenerated to match.

Don't use this skill when:

- The user just wants ASCII art or a wireframe sketch — those are
  conversational, not file artifacts.
- A backend-only spec is being drafted (data models, sync workers, protocol
  servers without UI). No mockup needed.

## How it works

```
caller → SKILL.md (you) → scripts/generate.sh → LiteLLM → Gemini → PNG → disk
```

The skill drives a five-step workflow:

1. **Resolve the visual identity** for the active project (read its
   `CLAUDE.md`).
2. **Resolve the output path** from caller intent + project conventions.
3. **Scan in arrears** — list existing mockups in the target directory and
   flag any that may be stylistically out of date.
4. **Construct the prompt** — three layers: browser-chrome envelope,
   visual identity, screen-specific description.
5. **Invoke `scripts/generate.sh`** with the prompt and output path. It
   handles env loading, the API call, file I/O, and opening the image.

Most of the deterministic work lives in `scripts/generate.sh`. Most of the
judgment work — what visual identity applies, what filename to use, what
older mockups need refreshing — lives in this SKILL.md.

## Step 1 — Resolve the visual identity

Visual identity lives in the active project's `CLAUDE.md`. Look for a section
heading that matches one of:

- `## Visual Identity`
- `## Style Guide`
- `## Mockup Style`
- `### Visual Identity` (subsection of Architecture Context)

Read that section in full. It typically describes color palette, typography,
component framework (Tailwind / DaisyUI / shadcn / custom), iconography (Hero
Icons / Lucide / Phosphor), motif/aesthetic notes, and example URL patterns.

If no such section exists, pause and ask the user:

> The project's `CLAUDE.md` doesn't have a `## Visual Identity` section. Want
> me to draft one based on the design ADR / spec for this project, or pass
> the visual identity directly as a one-shot for this mockup?

Don't fabricate a visual identity silently — let the user choose to either
formalize it in `CLAUDE.md` (recommended, durable) or pass it inline this
once.

## Step 2 — Resolve the output path

Two cases:

**Case A — caller specifies an explicit path.** Use it verbatim. The path
SHOULD be a stable filename (e.g., `01-login.png`, `account-dashboard.png`)
so that regenerating overwrites cleanly. Reject timestamp-style filenames
(`mockup_20260427_123456.png`) — they fragment the spec across versions.

**Case B — caller specifies a spec/capability and a screen name.** Default
the output path to:

```
<project-root>/docs/openspec/specs/<capability>/mockups/<NN>-<slug>.png
```

where `<NN>` is a two-digit ordinal (use the next available, or the natural
flow order if defined by the spec) and `<slug>` is a descriptive kebab-case
name. Create the parent directory if it doesn't exist.

Other common patterns to recognize:
- `<project-root>/docs/ui/<slug>.png`
- `<project-root>/.claude/mockups/<slug>.png`

Prefer the spec-adjacent location (`docs/openspec/specs/.../mockups/`) when a
spec is the driver — it keeps mockups reviewable next to the requirements
they illustrate.

## Step 3 — Scan in arrears

Before generating, list every existing image file in the target directory:

```bash
ls -la <output-dir>
```

For each existing mockup:

1. Read the file (the Read tool can render PNGs visually).
2. Compare its apparent style to the project's current visual identity from
   step 1.
3. If the older mockup looks like it predates a style change (wrong color
   palette, wrong framework aesthetic, light-mode where dark is now the
   spec, etc.), flag it.

Report the results to the user before generating the new mockup:

> Found 4 existing mockups in this directory. 3 match the current visual
> identity. 1 looks like it predates the dark-mode decision (`02-account-dashboard.png`)
> — want me to regenerate it after this one?

If everything looks current, just say so briefly and proceed.

The point of this step is to keep design artifacts honest: mockups that
contradict the current spec mislead reviewers and rot the design record.

## Step 4 — Construct the prompt

The prompt has three layers, concatenated in this order:

### Layer 1 — Browser chrome (universal)

Read `references/browser-chrome.md` and use the prompt fragment there. It
specifies macOS Safari window framing, traffic-light buttons, address bar,
tab bar, drop shadow on a neutral desktop background. This layer is the same
for every mockup; consistency matters because the framing tells the eye
"this is a mockup of a web app" at a glance.

Customize one detail: the address bar URL. Construct a plausible URL based
on:
- Project's deployment domain pattern (often documented in `CLAUDE.md`'s
  Deployment Context section).
- The route the screen would actually be at (e.g., `/auth/login`,
  `/accounts`, `/admin/accounts/42/settings`).

If the project has no documented deployment domain, default to
`https://<project-name>.example.com/<route>`.

### Layer 2 — Visual identity (project-specific)

Inline the visual identity prose from step 1, paraphrased to fit naturally
into an image-generation prompt. Don't quote the `CLAUDE.md` section
verbatim — translate it into descriptive language Gemini understands
(colors as hex or named hues, typography as named fonts, components as
"DaisyUI cards with rounded corners and soft shadows" rather than as
literal class names).

### Layer 3 — Screen description (caller-specific)

The caller's specific description of what this screen is and what's on it.
Be concrete: list the actual elements the user should see (header text,
button labels, input placeholders, sample data, navigation items). Use
realistic sample data — never lorem ipsum, never `username@example.com`
when the project's deployment context implies a different domain.

### Quality bar (universal, append at end)

Read `references/quality-bar.md` and append. It specifies things like:
"clean, modern, production-ready appearance — not wireframe, not sketch;
proper visual hierarchy with font-size variation; adequate whitespace;
photorealistic rendering quality." Same on every prompt — sets the floor.

## Step 5 — Invoke the generator

Run `scripts/generate.sh`. It expects:

- `--prompt <text>` — the full assembled prompt from step 4
- `--output <path>` — the absolute output path from step 2
- `--size <WxH>` — optional, defaults to `1536x1024` (3:2 desktop-feeling
  aspect, matches Gemini's preferred sizes)

The script:

- Re-execs itself under `bash -lc` if `OPENAI_BASE_URL`/`OPENAI_API_KEY`
  aren't set (these typically live in the user's login shell rc).
- Validates the model is reachable (`gemini-3-pro-image-preview` is
  primary; falls back to a sensible alternative if the response is a
  model-not-found error).
- POSTs to `$OPENAI_BASE_URL/v1/images/generations`.
- Decodes the base64 response.
- Writes to the output path, creating the parent directory.
- Opens the image (`xdg-open` on Linux, `open` on macOS) — only when a
  display is available; in headless environments, just reports the path.
- Exits 0 on success, non-zero with a clear error message on failure.

After the script returns, report to the user:

- The saved path.
- A one-line description of what was generated.
- Any in-arrears flags from step 3 — explicitly ask whether to regenerate
  them next.

## Examples

### Example 1: Spec-adjacent mockup

**Caller request:** "Mock up the login screen for SPEC-0005 of Reduit."

**Skill workflow:**

1. Read `~/src/reduit/CLAUDE.md` → find `## Visual Identity` section (or
   `### Visual Identity` under Architecture Context). Identity says: dark
   mode, deep indigo + slate, DaisyUI 5 on Tailwind 4, Heroicons, Inter
   font, alpine motif.
2. Output path: `~/src/reduit/docs/openspec/specs/admin-ui-flows/mockups/01-login.png`
   (next-available ordinal, descriptive slug).
3. Scan: `ls` of mockups directory returns nothing. Report "Empty mockups
   dir — no in-arrears candidates."
4. Build prompt: browser chrome with URL `https://reduit.family.tld/auth/login`
   + visual identity prose + screen description (large primary "Sign in
   with Pocket ID" button, footer with version, etc.) + quality bar.
5. Run `generate.sh --prompt "..." --output "/path/to/01-login.png"`.
6. Report: "Saved to `/path/to/01-login.png`. No in-arrears mockups to
   refresh."

### Example 2: One-shot mockup

**Caller request:** "Generate a mockup of the dashboard for joe-links and
save it to `/tmp/joe-links-dash.png`."

**Skill workflow:**

1. Read `~/src/joe-links/CLAUDE.md` → find visual identity (DaisyUI pastel
   theme, system-detect, etc.).
2. Output path is explicit: `/tmp/joe-links-dash.png`.
3. Scan: `ls /tmp/` for `joe-links-dash*` — none. Report empty.
4. Build prompt with the joe-links identity.
5. Run.
6. Report.

### Example 3: Visual-identity refresh

**Caller request:** "We just changed the spotter style guide to dark-only.
Regenerate the existing mockups under `docs/ui/`."

**Skill workflow:**

1. Read spotter's updated `CLAUDE.md` for the new identity.
2. Scan `docs/ui/`: list every `.png`, read each one, identify which
   look light-mode or otherwise stylistically off.
3. For each flagged file, derive its screen description from its filename
   and any spec reference, then regenerate using the new identity. Use
   the same filename to overwrite cleanly.
4. Report the regeneration manifest (which files, what changed in style).

## Tips

- **Run a quick smoke generation first** when working in a new project. A
  10-second test ensures the env vars are wired and the model is reachable
  before committing to a batch of 8 screens.
- **Batch by visual identity**, not by spec. If two specs in the same
  project share an identity, generate them in the same session so the
  prompt template stays warm.
- **Crop and inspect** the generated PNG with the Read tool after each
  generation. Image models occasionally hallucinate UI elements (an extra
  navbar, a phantom button); a quick visual check catches it before the
  mockup misleads a reviewer.
- **Don't argue with the model about exact pixel values.** If the output
  is close but the accent color is off, regenerate with a clearer prompt
  rather than asking the model to "shift it 10% more saturated." Image
  models don't reason about color spaces well.

## See also

- `scripts/generate.sh` — the generator script.
- `references/browser-chrome.md` — universal Layer 1 framing.
- `references/quality-bar.md` — universal Layer 4 quality floor.
- The bundled `mockup-generator` skill — older alternative, light-mode
  DaisyUI defaults, doesn't load login env. Use this skill instead when
  you have LiteLLM and want project-driven identity.
