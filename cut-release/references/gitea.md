# Gitea / Forgejo: verify CI, tag, and cut a release

This path covers both **Gitea** and **Forgejo** — Forgejo is a Gitea fork and
its REST API (`/api/v1`) and `tea` CLI are compatible. `api_base` from
`scripts/detect-forge.sh` is `https://<host>/api/v1`.

Every call goes through the `tea` CLI: a subcommand where one exists, `tea api`
(paths relative to `/api/v1/`) for the rest. Do not `curl` the API with a token
from the environment — agent shells usually have none, and a write made with an
empty token fails without anyone noticing. `OWNER/REPO` and `SHA` come from
discovery.

## Auth

`tea` keeps its own credential per login. Find the login for this host:

```bash
tea logins list          # the NAME whose URL matches the host
LOGIN=<that name>
```

Pass `--login "$LOGIN" --repo OWNER/REPO` on every command rather than trusting
the checkout. If no login matches, stop and ask the user to run `tea login add`
for the host — never guess, construct, or paste a token.

Two `tea` traps:

- **`tea api` exits 0 on an HTTP error** (a 404, for one). Read the body, or
  read the object back; the exit code proves nothing.
- **Never `tea --debug` or `tea api -i`** in a session that is recorded — both
  dump raw HTTP detail into the transcript, and debug output can carry the
  auth header.

## Verify CI

Gitea Actions (and external CI) report a **combined commit status**. Require it
green before releasing:

```bash
tea api --login "$LOGIN" repos/OWNER/REPO/commits/SHA/status \
  | jq -r '.state // .message'   # success | pending | failure | warning | error
```

For the per-check breakdown (to name the failing one):

```bash
tea api --login "$LOGIN" repos/OWNER/REPO/commits/SHA/statuses \
  | jq -r '.[] | "\(.status)\t\(.context)\t\(.target_url)"'
```

If the repo uses Gitea Actions, the runs and a failing job's log:

```bash
tea actions runs ls --login "$LOGIN" --repo OWNER/REPO --limit 10
tea actions runs logs --login "$LOGIN" --repo OWNER/REPO --job <job-id> <run-id>
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

Gitea creates the tag from `--target` if it doesn't already exist. Gitea has no
server-side "generate notes from PRs" flag, so build the changelog yourself (see
`references/versioning.md` → "Changelog") and pass it as a notes file:

```bash
tea releases create --login "$LOGIN" --repo OWNER/REPO \
  --tag "TAG" --target SHA \
  --title "TITLE" \
  --note-file ./RELEASE_NOTES.md
  # add --draft / --prerelease as needed,
  # and --asset ./dist/app-linux-amd64 (repeatable) to attach binaries
```

Attach an asset to an existing release:

```bash
tea releases assets create --login "$LOGIN" --repo OWNER/REPO "TAG" ./dist/app-linux-amd64
```

## Verify

Confirm the Release exists and report its URL:

```bash
tea api --login "$LOGIN" repos/OWNER/REPO/releases/tags/TAG \
  | jq -r '{name, tag_name, draft, prerelease, html_url, published_at, message}'
```

`html_url` is the link to give the user; a `message` of `not found` means no
release, whatever the exit code said. If automation cut the release, check
`tea actions runs ls` (or the repo's Actions tab) until the run finishes, then
re-query the release.
