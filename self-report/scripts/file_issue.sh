#!/usr/bin/env bash
# file_issue.sh — file a skill-self-report issue against joestump/claude-skills.
#
# Usage: file_issue.sh <skill-name> <title> <body-file>
#
# Tier 1 (GitHub MCP): handled by Claude directly, not this script.
# Tier 2 (gh CLI):     ensures skill:<name> label exists, then opens an issue
#                      with labels skill-self-report + skill:<name>.
# Tier 3 (fallback):   writes body to $SKILL_ISSUE_OUT_DIR/skill-issue-<name>.md
#                      and prints a prefilled URL.
#
# Call once per skill. If multiple skills tripped in the same session, invoke
# this script multiple times — never bundle.

set -euo pipefail

REPO="joestump/claude-skills"
CATEGORY_LABEL="skill-self-report"
SKILL_LABEL_COLOR="c5def5"
OUT_DIR="${SKILL_ISSUE_OUT_DIR:-/mnt/user-data/outputs}"

if [ "$#" -lt 3 ]; then
  echo "usage: $0 <skill-name> <title> <body-file>" >&2
  exit 2
fi

SKILL="$1"
TITLE="$2"
BODY_FILE="$3"
SKILL_LABEL="skill:${SKILL}"

if [ ! -f "$BODY_FILE" ]; then
  echo "body file not found: $BODY_FILE" >&2
  exit 2
fi

# Tier 2: gh CLI
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  # Ensure the per-skill label exists (idempotent).
  if ! gh label list --repo "$REPO" --limit 200 --json name -q '.[].name' \
       | grep -qx "$SKILL_LABEL"; then
    gh label create "$SKILL_LABEL" \
      --repo "$REPO" \
      --color "$SKILL_LABEL_COLOR" \
      --description "Self-reports filed by the ${SKILL} skill" \
      >/dev/null
  fi

  gh issue create \
    --repo "$REPO" \
    --label "$CATEGORY_LABEL" \
    --label "$SKILL_LABEL" \
    --title "$TITLE" \
    --body-file "$BODY_FILE"
  exit 0
fi

# Tier 3: fallback — write body and print prefilled URL
mkdir -p "$OUT_DIR"
FALLBACK_PATH="$OUT_DIR/skill-issue-${SKILL}.md"
cp "$BODY_FILE" "$FALLBACK_PATH"

# URL-encode the title (basic: spaces and a few specials)
encoded_title=$(printf '%s' "$TITLE" | sed -e 's/ /%20/g' -e 's/#/%23/g' -e 's/&/%26/g' -e 's/?/%3F/g')

echo "gh CLI unavailable. Wrote self-report to: $FALLBACK_PATH"
echo "Open this URL to file it manually:"
echo "https://github.com/$REPO/issues/new?labels=${CATEGORY_LABEL},${SKILL_LABEL}&title=${encoded_title}"
exit 0
