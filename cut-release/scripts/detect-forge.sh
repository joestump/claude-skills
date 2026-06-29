#!/usr/bin/env bash
# Discover the forge, owner, and repo from the git remote so the cut-release
# skill knows which path to take. Prints shell-friendly key=value lines and a
# short human summary on stderr. Safe to run read-only; makes one network
# probe only for non-GitHub hosts.
#
# Usage: scripts/detect-forge.sh [remote]   (default remote: origin)

set -euo pipefail

remote="${1:-origin}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not inside a git work tree" >&2
  exit 1
fi

# Pick the requested remote, else the first one defined. Read the raw configured
# URL (git config) rather than `git remote get-url`, because get-url applies any
# url.*.insteadOf rewrites — which can mask the real host (e.g. a proxy rewrite).
get_url() { git config --get "remote.$1.url" 2>/dev/null || git remote get-url "$1" 2>/dev/null || true; }

url="$(get_url "$remote")"
if [ -z "$url" ]; then
  remote="$(git remote | head -1)"
  [ -n "$remote" ] && url="$(get_url "$remote")"
fi
if [ -z "$url" ]; then
  echo "error: no git remote found — add one or pass a SHA/host explicitly" >&2
  exit 1
fi

# Normalize the remote URL into host / owner / repo.
# Handles: git@host:owner/repo.git, ssh://git@host[:port]/owner/repo.git,
#          https://host/owner/repo.git, https://user@host/owner/repo
host="" owner="" repo=""
stripped="$url"
stripped="${stripped%.git}"

case "$stripped" in
  *://*)
    # scheme://[user@]host[:port]/owner/repo
    rest="${stripped#*://}"
    rest="${rest#*@}"               # drop any user@
    host="${rest%%/*}"
    host="${host%%:*}"             # drop :port
    path="${rest#*/}"
    ;;
  *@*:*)
    # scp-like: [user@]host:owner/repo
    rest="${stripped#*@}"
    host="${rest%%:*}"
    path="${rest#*:}"
    ;;
  *)
    echo "error: could not parse remote URL: $url" >&2
    exit 1
    ;;
esac

owner="${path%%/*}"
repo="${path##*/}"

if [ -z "$host" ] || [ -z "$owner" ] || [ -z "$repo" ]; then
  echo "error: could not extract host/owner/repo from: $url" >&2
  exit 1
fi

# Default branch: prefer the remote HEAD, fall back to common names.
default_branch="$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2>/dev/null | sed "s#^$remote/##" || true)"
if [ -z "$default_branch" ]; then
  for b in main master trunk; do
    if git show-ref --verify --quiet "refs/remotes/$remote/$b"; then
      default_branch="$b"; break
    fi
  done
fi
[ -z "$default_branch" ] && default_branch="main"

# Classify the forge.
forge="unknown"
api_base=""
if [ "$host" = "github.com" ]; then
  forge="github"
  api_base="https://api.github.com"
elif command -v gh >/dev/null 2>&1 && gh auth status --hostname "$host" >/dev/null 2>&1; then
  # gh knows this host → treat as GitHub (Enterprise). API base is host/api/v3.
  forge="github"
  api_base="https://$host/api/v3"
else
  # Probe for Gitea/Forgejo, which both answer /api/v1/version.
  if ver="$(curl -fsS --max-time 8 "https://$host/api/v1/version" 2>/dev/null)" \
     && printf '%s' "$ver" | grep -q '"version"'; then
    forge="gitea"
    api_base="https://$host/api/v1"
  fi
fi

# Machine-readable on stdout.
echo "forge=$forge"
echo "host=$host"
echo "owner=$owner"
echo "repo=$repo"
echo "api_base=$api_base"
echo "default_branch=$default_branch"

# Human summary on stderr.
{
  echo ""
  echo "Forge:          $forge"
  echo "Host:           $host"
  echo "Repo:           $owner/$repo"
  echo "API base:       ${api_base:-<none — host not recognized>}"
  echo "Default branch: $default_branch"
  if [ "$forge" = "unknown" ]; then
    echo ""
    echo "Host not recognized as GitHub or Gitea. If it's GitHub Enterprise,"
    echo "run 'gh auth login --hostname $host' (or set GH_HOST=$host) and re-run."
    echo "Otherwise confirm with the user which forge this is."
  fi
} >&2
