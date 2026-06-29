# Gitea / Forgejo: verify CI, tag, and cut a release

This path covers both **Gitea** and **Forgejo** — Forgejo is a Gitea fork and
its REST API (`/api/v1`) and `tea` CLI are compatible. `api_base` from
`scripts/detect-forge.sh` is `https://<host>/api/v1`.

Use the `tea` CLI when it's logged in (`tea login list`); otherwise use the REST
API with `curl`. Both `OWNER/REPO`, `SHA`, and `API_BASE` come from discovery.

## Auth

Gitea doesn't ship with ambient auth like `gh`, so resolve a token first:

1. **Env var** — `GITEA_TOKEN` (or `FORGEJO_TOKEN`). Check `env | grep -iE 'gitea|forgejo'`.
2. **`tea` config** — if `tea login list` shows a login for this host, `tea`
   commands work without a token. Reuse it.
3. **Secrets manager** — check the project's `CLAUDE.md`/`.env.example` for a kv
   path (the same resolution order other skills in this repo use).
4. **Ask the user** — never guess or construct a token.

Create a token if needed: Gitea → Settings → Applications → Generate Token, with
at least `write:repository` scope. API auth header: `Authorization: token <TOKEN>`
(note: `token`, not `Bearer`).

```bash
GITEA="$API_BASE"          # e.g. https://gitea.stump.rocks/api/v1
AUTH="Authorization: token $GITEA_TOKEN"
```

## Verify CI

Gitea Actions (and external CI) report a **combined commit status**. Require it
green before releasing:

```bash
curl -fsS -H "$AUTH" "$GITEA/repos/OWNER/REPO/commits/SHA/status" \
  | jq -r '.state'        # success | pending | failure | warning | error
```

For the per-check breakdown (to name the failing one):

```bash
curl -fsS -H "$AUTH" "$GITEA/repos/OWNER/REPO/commits/SHA/statuses" \
  | jq -r '.[] | "\(.status)\t\(.context)\t\(.target_url)"'
```

With `tea` (if the repo uses Gitea Actions):

```bash
tea actions runs --repo OWNER/REPO     # eyeball recent runs and their status
```

Decision rule is identical to the GitHub path: proceed only on `success`. On
`pending`, it's still running — re-check a couple of times, then report. On
`failure`/`error`, stop and link `target_url`. If the repo has no CI at all,
say so and confirm with the user before releasing without a green signal.

## Create the tag (if not letting the release create it)

If the repo automates releases on tag push (check `.gitea/workflows/` or
`.forgejo/workflows/` for an `on: push: tags:` trigger), push only the tag:

```bash
git tag -a "TAG" SHA -m "TAG"
git push origin "TAG"
```

Otherwise the release call below will create the tag from `target` for you.

## Create the release

The Gitea API creates the tag from `target` if it doesn't already exist:

```bash
curl -fsS -X POST -H "$AUTH" -H "Content-Type: application/json" \
  "$GITEA/repos/OWNER/REPO/releases" \
  -d '{
        "tag_name": "TAG",
        "target_commitish": "SHA",
        "name": "TITLE",
        "body": "RELEASE NOTES (markdown)",
        "draft": false,
        "prerelease": false
      }'
```

Gitea has no server-side "generate notes from PRs" flag, so build the changelog
yourself (see `references/versioning.md` → "Changelog") and pass it as `body`.

With `tea`:

```bash
tea release create --repo OWNER/REPO \
  --tag "TAG" --target SHA \
  --title "TITLE" \
  --note "RELEASE NOTES" \
  # --draft / --prerelease as needed \
  # --asset ./dist/app-linux-amd64 --asset ./dist/app-darwin-arm64
```

Attach an asset to an existing release via API:

```bash
RELEASE_ID=$(curl -fsS -H "$AUTH" "$GITEA/repos/OWNER/REPO/releases/tags/TAG" | jq -r '.id')
curl -fsS -X POST -H "$AUTH" \
  -F "attachment=@./dist/app-linux-amd64" \
  "$GITEA/repos/OWNER/REPO/releases/$RELEASE_ID/assets?name=app-linux-amd64"
```

## Verify

Confirm the Release exists and report its URL:

```bash
curl -fsS -H "$AUTH" "$GITEA/repos/OWNER/REPO/releases/tags/TAG" \
  | jq -r '{name, tag_name, draft, prerelease, html_url, published_at}'
```

`html_url` is the link to give the user. If automation cut the release, check
`tea actions runs` (or the repo's Actions tab) until the run finishes, then
re-query the release.
