---
name: refresh-miatrix-token
description: >
  Refresh the Miatrix indexer API token in Prowlarr by logging into Miatrix
  via browser automation and extracting the current API key. Use this skill
  whenever Miatrix keeps re-downloading the same episodes or shows, when
  Prowlarr reports Miatrix indexer errors or failures, or when a Miatrix API
  key rotation is suspected. The skill handles the full workflow automatically:
  gathers credentials, logs into Miatrix, grabs the API key from the profile
  page, and updates Prowlarr's indexer config — no manual steps required.
---

# Refresh Miatrix Token

Fixes the "re-downloading the same show" symptom caused by Miatrix API key
rotation. When Miatrix rotates its keys, Prowlarr's cached key goes stale
and Miatrix starts returning duplicate or incorrect results — causing the Arr
stack to re-queue already-downloaded episodes.

## Step 1: Gather required credentials

You need four values before proceeding:

| Variable | Description |
|----------|-------------|
| `MIATRIX_USER` | Miatrix username or email |
| `MIATRIX_PASS` | Miatrix password |
| `PROWLARR_URL` | Base URL of the Prowlarr instance (e.g. `https://prowlarr.example.com`) |
| `PROWLARR_KEY` | Prowlarr API key (Settings → General → API Key) |

Resolve them in this order of preference:

1. **Already set in the environment** — check with `env | grep -E 'MIATRIX|PROWLARR'`
2. **Secrets manager** — read from whatever the project uses (Vault/OpenBao,
   1Password CLI, Bitwarden CLI, `pass`, etc.). The project's `CLAUDE.md` or
   `.env.example` usually documents the path.
3. **Ask the user** — if credentials are not findable, ask for them directly.
   Never guess or construct them.

Once resolved, assign them:
```bash
MIATRIX_USER="<value>"
MIATRIX_PASS="<value>"
PROWLARR_URL="<value>"   # no trailing slash
PROWLARR_KEY="<value>"
```

Never log, echo, or display credential values. If any value cannot be
resolved, stop and report which one is missing.

## Step 2: Log into Miatrix via Chrome DevTools

Open a fresh browser tab and navigate to the login page.

```
new_page → get the page_id
navigate_page(page_id, "https://miatrix.com/login")
wait_for(page_id, ["Login", "Username", "Email", "Password"])
take_snapshot(page_id)
```

Fill in the credentials and submit. Common selector patterns for the form:
- Username/Email: `input[name="username"]`, `input[type="email"]`, `#username`, `#email`
- Password: `input[type="password"]`
- Submit: `button[type="submit"]`, `input[type="submit"]`

```
fill(page_id, <username_selector>, MIATRIX_USER)
fill(page_id, <password_selector>, MIATRIX_PASS)
click(page_id, <submit_selector>)
wait_for(page_id, ["networkidle", "Dashboard", "Profile", "Welcome"])
```

Verify login succeeded: the URL should no longer be `/login` and a snapshot
should show the user's account name or a dashboard, not an error message. If
still on the login page, **stop immediately** and report:
> "Miatrix login failed — verify MIATRIX_USER and MIATRIX_PASS"

Do not retry with modified credentials.

## Step 3: Extract the API key from the profile page

```
navigate_page(page_id, "https://miatrix.com/profile")
wait_for(page_id, ["networkidle", "API", "Key", "Token"])
take_snapshot(page_id)
```

The API key is visible as a text value or readonly input labelled "Site
Api/Rss Key" or similar. Try extracting it with `evaluate_script`:

```javascript
(function() {
  const selectors = [
    'input[name*="api"]', 'input[id*="api"]',
    'input[name*="key"]', 'input[id*="key"]',
    'input[name*="token"]',
    '.api-key', '.apikey', '[data-apikey]', '[data-api-key]',
  ];
  for (const sel of selectors) {
    const el = document.querySelector(sel);
    if (el) return el.value || el.textContent.trim();
  }
  // Fall back: scan code/pre blocks for a plausible API key string
  for (const el of document.querySelectorAll('code, pre, .token, .key')) {
    const text = el.textContent.trim();
    if (text.length > 16 && /^[a-zA-Z0-9_\-]+$/.test(text)) return text;
  }
  return null;
})()
```

If the script returns null, read the snapshot — the key may be in a
button-revealed modal or "copy" widget. Click a "Show" or "Reveal" button
first, then re-evaluate. If you still cannot extract it, take a screenshot
and report the page structure so the selector can be updated.

Store the result as `NEW_API_KEY`. Close the browser tab when done:
```
close_page(page_id)
```

## Step 4: Update Prowlarr's Miatrix indexer

Find the Miatrix indexer(s):
```bash
curl -s -H "X-Api-Key: $PROWLARR_KEY" \
  "$PROWLARR_URL/api/v1/indexer" \
  | python3 -c "
import sys, json
indexers = json.load(sys.stdin)
for i in indexers:
    name = i.get('name','').lower()
    defn = i.get('definitionName','').lower()
    if 'miatrix' in name or 'miatrix' in defn:
        print(i['id'], i['name'])
"
```

If no indexer is found, list all indexer names and report — the name in
Prowlarr may differ from "Miatrix".

For each Miatrix indexer found, GET the full config, patch the API key field,
and PUT it back. Use temp files to keep the shell pipeline simple:

```bash
# GET full config
curl -s -H "X-Api-Key: $PROWLARR_KEY" \
  "$PROWLARR_URL/api/v1/indexer/$INDEXER_ID" \
  > /tmp/prowlarr_indexer.json

# Patch the apiKey field (commonly named apiKey, key, api_key, passkey, or token)
python3 - <<PYEOF > /tmp/prowlarr_patched.json
import json, sys

with open('/tmp/prowlarr_indexer.json') as f:
    data = json.load(f)

new_key = "$NEW_API_KEY"
key_fields = {'apiKey', 'key', 'api_key', 'passkey', 'apikey', 'token'}
updated = False
for field in data.get('fields', []):
    if field.get('name', '').lower() in key_fields:
        field['value'] = new_key
        updated = True
        break
if not updated:
    print('Available fields:', [f['name'] for f in data.get('fields', [])], file=sys.stderr)
    sys.exit(1)

with open('/tmp/prowlarr_patched.json', 'w') as out:
    json.dump(data, out)
PYEOF

# PUT back and capture HTTP status
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -X PUT \
  -H "X-Api-Key: $PROWLARR_KEY" \
  -H "Content-Type: application/json" \
  -d @/tmp/prowlarr_patched.json \
  "$PROWLARR_URL/api/v1/indexer/$INDEXER_ID")

rm -f /tmp/prowlarr_indexer.json /tmp/prowlarr_patched.json
echo "Prowlarr responded: $HTTP_STATUS"
```

A `200` or `202` response means success. If the Python script exits with error
(field not found), print the available field names so the skill can be updated
with the correct field name.

## Step 5: Verify and report

Test the updated indexer directly:
```bash
curl -s -X POST \
  -H "X-Api-Key: $PROWLARR_KEY" \
  "$PROWLARR_URL/api/v1/indexer/$INDEXER_ID/test"
```

Report the outcome clearly:
```
✓ Retrieved new Miatrix API key from https://miatrix.com/profile
✓ Updated Prowlarr indexer "<name>" (ID: N) at <PROWLARR_URL>
  → Prowlarr responded: 202
  → Indexer test: passed
```

On any failure, state the exact step that failed and the error. Do not
include credential values in the output.
