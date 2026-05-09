# claude-skills

Mono-repo of personal Claude skills. Each top-level directory (other than `.github/`) is one self-contained skill with its own `SKILL.md`, references, and assets.

## Versioning & tagging

Skills version **independently** using per-skill tags:

```
<skill-name>-v<MAJOR>.<MINOR>.<PATCH>
```

Examples:

- `retirement-plan-v1.0.0` — first stable release of the retirement-plan skill
- `retirement-plan-v1.1.0` — added a tab or knob
- `retirement-plan-v1.1.1` — bug fix in the template

Rules:

- Tag from `main` after the change is merged.
- One skill per tag. Don't bundle multiple skills into one tag.
- Don't use a global `v*` tag — skills are unrelated and shouldn't share a version.
- Follow semver: breaking changes to a skill's contract bump MAJOR, additive changes MINOR, fixes PATCH.

The release workflow (`.github/workflows/release-skill.yml`) parses the skill name from the tag, zips that directory, and attaches `<skill-name>.zip` to a GitHub Release.

### Cutting a release

```sh
git tag retirement-plan-v1.2.0
git push origin retirement-plan-v1.2.0
```

GitHub Actions handles the rest.
