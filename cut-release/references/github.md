# GitHub: verify CI, tag, and cut a release

Use the `gh` CLI when it's authenticated (`gh auth status`); fall back to the
REST API with `curl` + a token when `gh` isn't available. `gh` reads
`GH_TOKEN`/`GITHUB_TOKEN` and respects `GH_HOST` for GitHub Enterprise. For raw
API calls, `api_base` is `https://api.github.com` (github.com) or
`https://<host>/api/v3` (Enterprise), with header `Authorization: Bearer <token>`
and `Accept: application/vnd.github+json`.

Throughout, `OWNER/REPO` and `SHA` come from `scripts/detect-forge.sh` and Step 1.

## Verify CI

A commit can carry both legacy **commit statuses** and **check-runs**. Check
both; require both green.

With `gh` (simplest — this is the merged combined view used by branch
protection):

```bash
# Combined commit status (legacy statuses): state is success | pending | failure
gh api "repos/OWNER/REPO/commits/SHA/status" --jq '.state'

# Check-runs: every run's conclusion must be success/neutral/skipped (not failure,
# cancelled, timed_out) and status must be completed.
gh api "repos/OWNER/REPO/commits/SHA/check-runs" \
  --jq '.check_runs[] | {name, status, conclusion}'
```

Quick all-in-one for the latest commit on a branch:

```bash
gh run list --branch BRANCH --limit 10           # eyeball recent workflow runs
gh pr checks <pr-number>                          # if releasing right after a PR
```

Decision: proceed only if combined `state == success` AND every check-run is
`completed` with a passing `conclusion`. If anything is `pending`/`in_progress`,
it's still running — re-check a couple of times, then report and let the user
decide. If anything failed, stop and link it:

```bash
gh run view <run-id> --log-failed        # surface the failing step
```

Raw API equivalent:

```bash
curl -fsS -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github+json" \
  "$API_BASE/repos/OWNER/REPO/commits/SHA/status" | jq -r '.state'
```

## Create the tag (if not letting the release create it)

If the repo has release automation that fires on tag push (check
`.github/workflows/*` for `on: push: tags:`), **push only the tag** and let the
workflow cut the release:

```bash
git tag -a "TAG" SHA -m "TAG"
git push origin "TAG"
```

Otherwise you can skip a manual tag entirely — `gh release create` will create
the tag at `--target` for you (next section).

## Create the release

`gh` creates the tag (at `--target`, default the repo's default branch) and the
release in one call:

```bash
gh release create "TAG" \
  --target SHA \
  --title "TITLE" \
  --generate-notes            # auto changelog from merged PRs since last release
```

Common variations:

```bash
# Hand-written notes instead of / in addition to generated ones:
gh release create "TAG" --target SHA --title "TITLE" --notes-file NOTES.md

# Combine generated notes with a lead-in blurb:
gh release create "TAG" --target SHA --title "TITLE" \
  --generate-notes --notes-start-tag PREVIOUS_TAG

# Prerelease (rc/beta/alpha) or draft for review before publishing:
gh release create "TAG" --target SHA --title "TITLE" --generate-notes --prerelease
gh release create "TAG" --target SHA --title "TITLE" --generate-notes --draft

# Attach build assets (repeat the path args):
gh release create "TAG" --target SHA --title "TITLE" --generate-notes \
  ./dist/app-linux-amd64 ./dist/app-darwin-arm64
```

Raw API (creates the tag from `target_commitish` if the tag doesn't exist):

```bash
curl -fsS -X POST \
  -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github+json" \
  "$API_BASE/repos/OWNER/REPO/releases" \
  -d '{
        "tag_name": "TAG",
        "target_commitish": "SHA",
        "name": "TITLE",
        "generate_release_notes": true,
        "draft": false,
        "prerelease": false
      }'
```

Upload an asset to an existing release via API:

```bash
RELEASE_ID=$(gh api "repos/OWNER/REPO/releases/tags/TAG" --jq '.id')
curl -fsS -X POST \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Content-Type: application/octet-stream" \
  "https://uploads.github.com/repos/OWNER/REPO/releases/$RELEASE_ID/assets?name=app-linux-amd64" \
  --data-binary @./dist/app-linux-amd64
```

## Verify

Confirm the Release object exists (not just the tag) and grab its URL:

```bash
gh release view "TAG" --json name,tagName,isDraft,isPrerelease,url,publishedAt
# or: gh release view "TAG" --web   to open it
```

If release automation was supposed to cut it, the workflow may still be running:

```bash
gh run list --workflow release-skill.yml --limit 3
```

Wait for it to finish, then `gh release view "TAG"` to confirm.

## GitHub Enterprise

Same commands; just make sure `gh` is pointed at the right host:

```bash
gh auth login --hostname github.mycorp.com     # one-time
export GH_HOST=github.mycorp.com               # or pass per-call via --hostname
```

For raw API, `API_BASE=https://github.mycorp.com/api/v3` and uploads go to
`https://github.mycorp.com/api/uploads/...`.
