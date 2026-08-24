---
name: pr-sweep
description: >
  Sweep Joe's open pull requests across GitHub (github.com/joestump) and Gitea
  (gitea.stump.rocks) and drive each one toward merge — checking CI, mergeability,
  and review state, then acting: on PRs the acting account authored it pushes
  fixes for failing checks and review findings and replies to the threads (but
  never merges its own work); on PRs authored by someone else it merges the ones
  that are green, approved, and conflict-free. Use this skill whenever Joe says
  "sweep my PRs", "sweep my open PRs", "check/work/shepherd my open PRs", "merge
  my ready PRs", "clear my PR queue", "go through joestump-agent's PRs", or
  otherwise wants his open pull requests triaged and moved forward. "My" resolves
  to joestump-agent when `whoami` is joestump-agent, otherwise joestump, and can
  be overridden with `--username <login>`. Covers both hosts by default.
category: Dev
tags: [github, gitea, pull-requests, review, ci, automation, merge]
status: stable
---

# PR Sweep

Walk every open pull request **you** authored and move it toward a terminal
state — merged, or fixed and waiting on a human LGTM — so the queue drains
without you babysitting each one. Joe opens a lot of PRs from `joestump-agent`;
this is how they get shepherded to green and merged.

## The one rule that governs everything: no self-merge

An account must not merge its own pull requests. That separation of duties is
the whole point of review — the author gets a PR ready, a *different* identity
provides the final LGTM and the merge. So this skill decides what it may do by
comparing the **acting account** (whoever the tokens are authenticated as) to the
PR's **author**:

- **`self` mode** — acting account **is** the author. Never merge. The job is to
  get the PR *ready*: push fixes for failing CI and review findings, reply to the
  threads, and report it as "ready, awaiting merge by another identity."
- **`merge` mode** — acting account is **not** the author. The ready PRs (green +
  approved + mergeable, not draft) get merged. Not-ready ones get reported, and
  you may leave a review, but don't push commits onto someone else's branch
  unless you clearly have write access and it's obviously wanted.

The practical shape of this: run it plainly on your laptop (`whoami=joestump`,
`gh` authed as `joestump`) and it sweeps *your own* PRs in `self` mode — fixes
and replies, never merges. Run it with `--username joestump-agent` while authed
as `joestump` and it sweeps the agent's PRs in `merge` mode — merging the ones
the agent already got green. That's Joe merging the agent's work from his own
account, exactly as a second reviewer would.

## Step 1 — Resolve identity and mode

Run the bundled script. It resolves the target author, reports the acting GitHub
login, computes the mode, and lists the target's open GitHub PRs. Pass through
`--username` if the user gave one:

```bash
scripts/list-open-prs.sh [--username <login>]
```

Line 1 is a JSON header — `{host, target_user, acting_user, mode}` — and the rest
is the `gh search prs` array. Read the header: it tells you whether GitHub is in
`self` or `merge` mode for this run.

For **Gitea**, determine the acting identity with the Gitea MCP `get_me` tool and
compare its login to `target_user` the same way (equal → `self`, different →
`merge`). Find the target's open Gitea PRs with `mcp__gitea__search_issues`
(type `pulls`, state `open`, filtered to the target as poster) — or, if that's
awkward, enumerate the handful of repos the target actually opens PRs against
(`stumpcloud/*`, `joestump/*`) with `list_pull_requests` and keep the ones the
target authored. The two hosts can legitimately be in *different* modes if the
Gitea token and the `gh` token are different accounts — evaluate each host on its
own.

If a host has no credentials configured, say so and sweep the other host rather
than failing the whole run.

## Step 2 — Gather each PR's state

For every open PR in the target set, collect enough to decide:

- **CI / checks** — passing, failing, pending, or none.
  GitHub: `gh pr checks <n> -R <owner/repo>` or `gh pr view <n> -R <repo> --json statusCheckRollup`.
  Gitea: `mcp__gitea__actions_run_read` for the head SHA (Gitea Actions can be
  flaky to query — if you can't get status, say "CI unknown" rather than guessing).
- **Mergeability** — clean, or conflicts / behind base.
  GitHub: `--json mergeable,mergeStateStatus`. Gitea: `pull_request_read` `.mergeable`.
- **Review state** — approved, changes requested, or no review yet.
  GitHub: `--json reviewDecision,reviews`. Gitea: read the PR's reviews.
- **Open threads / findings** — unresolved review comments or review-bot findings
  that ask for a change. These are what `self` mode acts on.

## Step 3 — Decide and act, one PR at a time

Work them individually — finish one before starting the next — so a failure on
one PR never strands another half-done. Apply this table:

| PR state | `self` mode (you authored it) | `merge` mode (someone else did) |
|----------|-------------------------------|---------------------------------|
| Green + approved + mergeable, not draft | Report **ready — awaiting external merge**. Don't merge. | **Merge it.** |
| Failing CI | Reproduce, **push a fix** to the PR branch, reply on the failing thread. | Report the failure; leave a review noting it. Don't push. |
| Changes requested / open review findings | **Address them**: push code fixes, then **reply to each thread** saying what you did. | Report; optionally re-review. Don't push. |
| Conflicts / behind base | Update the branch (rebase/merge base in), push. | Report; you may `update_branch` if the host offers it. |
| Draft | Leave it — drafts are intentionally not ready. Note it in the summary. | Leave it. |
| Clearly obsolete / superseded | **Flag it** for Joe with why — do **not** close it. Closing is the grooming skill's job, not this one. | Same — flag, don't close. |

Two things this skill never does: **merge its own PRs**, and **close anyone's
PRs**. Both are deliberate — the first is the safety invariant, the second keeps
this tool focused on *advancing* PRs (grooming/closing stale ones lives in the
`weekly-issue-pr-grooming` skill).

## Pushing fixes (self mode)

When a PR you authored has failing CI or requested changes, actually fix it:

1. Check out the PR branch (`gh pr checkout <n> -R <repo>`; for Gitea, fetch the
   head branch).
2. Reproduce the failure locally where you can, make the change, and keep the fix
   scoped to what the CI failure or review comment asked for.
3. Commit and push to the PR branch.
4. **Reply to each thread you addressed** — quote or reference the specific
   finding and say what you changed, so the reviewer can see it was handled. Then
   post a short top-level comment summarizing the push if several threads moved.

This is the same motion as responding to review feedback on a single PR, applied
across all of them.

### Attribution when you comment

If the **acting account is `joestump`** (you're posting as Joe), end each comment
and reply with Joe's attribution footer, per his global CLAUDE.md — a blank line,
then exactly:

```
🤖 Posted on behalf of `@joestump` by [Claude](https://claude.ai).
```

Keep `@joestump` in backticks (so it doesn't fire a live mention) and use **no**
horizontal rule before it. If the acting account is `joestump-agent`, it's the
agent's own account — post normally, no footer.

## Merging (merge mode)

Merge only when all of these hold: checks green (or none required), review
decision approved (or the repo requires none), `mergeable` is clean, and the PR
isn't a draft. Respect the repo's merge style — if unsure, a plain merge commit
is the safe default.

- GitHub: `gh pr merge <n> -R <owner/repo> --merge` (or the repo's preferred
  `--squash`/`--rebase`), or `mcp__github__merge_pull_request`.
- Gitea: `mcp__gitea__pull_request_write` method `merge`.

If a PR *looks* ready but something's off (branch protection, a required check
still pending), don't force it — report the blocker.

## Output — end with a summary

Close every run with a compact table so Joe sees the whole sweep at a glance:

```
PR Sweep — target: <user>  ·  github: <mode>  ·  gitea: <mode>

MERGED
  ✅ joestump-agent/crush#175 — retry transient Windows rename failures

FIXED & PUSHED (awaiting merge)
  🔧 joestump/msgbrowse#216 — fixed hermetic config test, replied on thread

READY — needs external LGTM
  🟢 joestump/reduit#42 — green + approved (self mode: won't self-merge)

BLOCKED / REPORTED
  ⚠️ joestump/spotter#88 — CI failing (flaky integration test), pushed retry
  🧷 joestump/foo#12 — conflicts with base, rebased and pushed

SKIPPED
  📝 joestump/bar#9 — draft
```

Link every PR by URL (Joe's rule: never name something linkable without its
link). If this was run from a scheduled task, also send the Signal Note-to-Self
summary his scheduled-task convention requires.

## Safety and scope

- **Dry run**: if Joe says "dry run" (or "just show me"), do Steps 1–2 and print
  the decision table with what you *would* do — take no writes.
- **One at a time**, and stop to ask if something's ambiguous (a merge conflict
  you can't cleanly resolve, a review finding you don't understand). Better to
  report it than guess.
- **Never merge your own PRs; never close PRs.** Restated because they're the two
  lines this skill must not cross.
