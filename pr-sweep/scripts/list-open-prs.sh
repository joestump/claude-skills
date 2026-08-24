#!/usr/bin/env bash
# Resolve the target PR author and list their open GitHub PRs, plus report the
# acting (authenticated) GitHub identity and the resulting mode.
#
# The mode is the whole safety story of this skill:
#   self  -> acting account == target author. NEVER merge (no self-merge);
#            only push fixes and reply to review findings.
#   merge -> acting account != target author. The ready PRs may be merged.
#
# Because every PR this lists is authored by <target> (that's the search
# filter), comparing the acting login to <target> once is equivalent to
# comparing it per-PR — so the mode is computed once here.
#
# Usage: list-open-prs.sh [--username <login>]
#   --username  Override the target author. Default: joestump-agent when
#               `whoami` is joestump-agent, otherwise joestump.
#
# Output: line 1 is a JSON header {host,target_user,acting_user,mode};
#         line 2+ is the `gh search prs` JSON array of open PRs.
set -euo pipefail

target=""
while [ $# -gt 0 ]; do
  case "$1" in
    --username) target="${2:-}"; shift 2 ;;
    --username=*) target="${1#*=}"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$target" ]; then
  if [ "$(whoami)" = "joestump-agent" ]; then target="joestump-agent"; else target="joestump"; fi
fi

command -v gh >/dev/null 2>&1 || { echo "ERROR: gh CLI not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq not found" >&2; exit 1; }

actor="$(gh api user -q .login 2>/dev/null || true)"
if [ -z "$actor" ]; then
  echo "ERROR: gh is not authenticated. Run: gh auth status" >&2
  exit 1
fi

if [ "$actor" = "$target" ]; then mode="self"; else mode="merge"; fi

jq -cn --arg t "$target" --arg a "$actor" --arg m "$mode" \
  '{host:"github", target_user:$t, acting_user:$a, mode:$m}'

# All of the target's open PRs across GitHub (their own repos and any upstreams
# they've contributed to). --limit is generous; raise it if the queue is huge.
gh search prs --author="$target" --state=open \
  --json number,title,url,repository,isDraft,createdAt,updatedAt \
  --limit 100
