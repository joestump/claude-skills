#!/usr/bin/env bash
# file_issue.sh — file a skill-self-report issue against joestump/claude-skills.
#
# Usage: file_issue.sh <title> <body-file>
#
# Tier 1 (GitHub MCP): handled by Claude directly, not this script.
# Tier 2 (gh CLI):     gh issue create --repo joestump/claude-skills --label skill-self-report
# Tier 3 (fallback):   write body to $SKILL_ISSUE_OUT_DIR/skill-issue.md and print a prefilled URL.

set -euo pipefail

REPO="joestump/claude-skills"
LABEL="skill-self-report"
OUT_DIR="${SKILL_ISSUE_OUT_DIR:-/mnt/user-data/outputs}"

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <title> <body-file>" >&2
  exit 2
fi

TITLE="$1"
BODY_FILE="$2"

if [ ! -f "$BODY_FILE" ]; then
  echo "body file not found: $BODY_FILE" >&2
  exit 2
fi

# Tier 2: gh CLI
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  gh issue create \
    --repo "$REPO" \
    --label "$LABEL" \
    --title "$TITLE" \
    --body-file "$BODY_FILE"
  exit 0
fi

# Tier 3: fallback — write body and print prefilled URL
mkdir -p "$OUT_DIR"
FALLBACK_PATH="$OUT_DIR/skill-issue.md"
cp "$BODY_FILE" "$FALLBACK_PATH"

# URL-encode the title (basic — spaces and a few specials)
encoded_title=$(printf '%s' "$TITLE" | sed -e 's/ /%20/g' -e 's/#/%23/g' -e 's/&/%26/g' -e 's/?/%3F/g')

echo "gh CLI unavailable. Wrote self-report to: $FALLBACK_PATH"
echo "Open this URL to file it manually:"
echo "https://github.com/$REPO/issues/new?labels=$LABEL&title=$encoded_title"
exit 0
