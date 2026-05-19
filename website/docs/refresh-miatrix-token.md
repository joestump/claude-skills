---
sidebar_position: 4
title: refresh-miatrix-token
---

# refresh-miatrix-token

Fixes the "re-downloading the same show" symptom caused by Miatrix API key rotation. When Miatrix rotates keys, Prowlarr's cached key goes stale and Miatrix returns duplicate or incorrect results — causing Sonarr, Radarr, and friends to re-queue already-downloaded episodes.

[**Source on GitHub →**](https://github.com/joestump/claude-skills/tree/main/refresh-miatrix-token)

## What it does

End-to-end automation in one command:

1. Reads your Miatrix credentials and Prowlarr API key from your secrets store (or prompts you)
2. Logs into `miatrix.com` via browser automation (Chrome DevTools MCP)
3. Extracts the current API key from your profile page
4. Finds the Miatrix indexer in Prowlarr and patches the `apiKey` field
5. Runs a targeted indexer test and reports the result

No manual copy-pasting of keys, no digging through Prowlarr settings.

## When to use

Trigger this skill when:

- Sonarr/Radarr/Lidarr keeps re-downloading episodes you already have
- Prowlarr's Miatrix indexer shows errors or `isValid: false`
- You suspect Miatrix has rotated its API keys (this happens periodically)
- You want to proactively sync the key after a known rotation event

## Prerequisites

- **Chrome DevTools MCP** configured in your Claude Code session — the skill uses browser automation to log into Miatrix
- **Miatrix credentials**: username/email and password (can live in a secrets manager or be supplied directly)
- **Prowlarr API key**: found at Settings → General → Security → API Key
- **Prowlarr URL**: the base URL of your Prowlarr instance

## Installation

```sh
cp -r refresh-miatrix-token ~/.claude/skills/
```

Claude Code picks it up automatically on the next session.

## How it works

The skill uses a five-step workflow:

### 1 — Credential resolution

The skill looks for `MIATRIX_USER`, `MIATRIX_PASS`, `PROWLARR_URL`, and `PROWLARR_KEY` in your environment, your project's secrets manager, or asks you directly if they're not found. Nothing is hardcoded — it works with any Prowlarr instance and any secrets backend.

### 2 — Browser login

Using the Chrome DevTools MCP, the skill opens a headless browser tab, navigates to `https://miatrix.com/login`, fills in your credentials, and submits the form. If login fails, it stops immediately and reports the error — it never retries with guessed credentials.

### 3 — API key extraction

After login, it navigates to `https://miatrix.com/profile` and extracts your current "Site Api/Rss Key" from the page. This is the freshly-rotated key that Prowlarr needs.

### 4 — Prowlarr update

The skill calls the Prowlarr REST API to find your Miatrix indexer, patches the `apiKey` field with the new value, and PUTs the updated config back. A `200` or `202` response confirms the update.

### 5 — Verification

It runs a targeted test on the updated indexer (`GET /api/v1/indexer/{id}/test`) and reports whether it passes. No other indexers are affected.

## Secrets manager integration

The credential resolution step is intentionally generic — the skill follows your project's conventions. Examples:

**OpenBao / HashiCorp Vault:**
```bash
MACHINE_TOKEN=$(cat /run/vault-agent/token)
MIATRIX_USER=$(curl -s -H "X-Vault-Token: $MACHINE_TOKEN" \
  https://vault.example.com/v1/secret/data/miatrix \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['data']['MIATRIX_USER'])")
```

**1Password CLI:**
```bash
MIATRIX_USER=$(op read "op://Personal/Miatrix/username")
MIATRIX_PASS=$(op read "op://Personal/Miatrix/password")
PROWLARR_KEY=$(op read "op://Homelab/Prowlarr/api_key")
```

**Environment variables:**
```bash
export MIATRIX_USER="your_username"
export MIATRIX_PASS="your_password"
export PROWLARR_URL="https://prowlarr.example.com"
export PROWLARR_KEY="your_prowlarr_api_key"
```

## Troubleshooting

**"Miatrix login failed"**

Verify your credentials are correct by logging in manually at `https://miatrix.com/login`. Update them in your secrets store and try again.

**"No Miatrix indexer found"**

The skill searches Prowlarr indexers for names or `definitionName` values containing "miatrix". If your indexer has a custom name (e.g. "MyIndexer"), look in Prowlarr's indexer list and confirm which one is Miatrix.

**"Chrome DevTools MCP not available"**

The browser automation step requires the Chrome DevTools MCP to be configured. Check that it's enabled in your Claude Code MCP settings and that a browser is running.

**Indexer test returns `isValid: false`**

If the test fails after the update, Miatrix may be temporarily down or the credentials may still be wrong. Check `https://miatrix.com` directly, then re-run the skill once the site is back.
