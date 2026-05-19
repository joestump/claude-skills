---
name: refresh-miatrix-token
description: >
  Refresh the Miatrix indexer API token in Prowlarr by logging into Miatrix
  via browser automation and extracting the current API key. Use this skill
  whenever Miatrix keeps re-downloading the same episodes or shows, when
  Prowlarr reports Miatrix indexer errors or failures, or when a Miatrix API
  key rotation is suspected. The skill handles the full workflow automatically:
  reads credentials from OpenBao, logs into Miatrix, grabs the API key from
  the profile page, and updates Prowlarr's indexer config — no manual steps
  required.
---

# Refresh Miatrix Token

Fixes the "re-downloading the same show" symptom caused by Miatrix API key
rotation. When Miatrix rotates its keys, Prowlarr's cached key goes stale
and Miatrix starts returning duplicate or incorrect results — causing the Arr
stack to re-queue already-downloaded episodes.

## Step 1: Read credentials from OpenBao

Use the machine token at `/run/vault-agent/token`. The AppRole policy doesn't
allow `sys/internal/ui/mounts`, so use the raw API — not `bao kv get`:

```bash
MACHINE_TOKEN=$(cat /run/vault-agent/token)

# Fetch Miatrix creds
_vault_users=$(curl -s \
  -H "X-Vault-Token: $MACHINE_TOKEN" \
  https://vault.stump.rocks/v1/secret/data/users/joestump)

MIATRIX_USER=$(echo "$_vault_users" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d['data']['data']['MIATRIX_USER'])")
MIATRIX_PASS=$(echo "$_vault_users" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d['data']['data']['MIATRIX_PASS'])")
unset _vault_users

# Fetch Prowlarr API key
PROWLARR_KEY=$(curl -s \
  -H "X-Vault-Token: $MACHINE_TOKEN" \
  https://vault.stump.rocks/v1/secret/data/ie01/arr \
  | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d['data']['data']['prowlarr_api_key'])")
```

Never log, echo, or display credential values. If either fetch returns empty
or an error object, stop and report which vault path failed.

## Step 2: Log into Miatrix via Chrome DevTools

Use `mcp__chrome-devtools__new_page` to open a fresh tab, then navigate to
the login page.

```
new_page → get the page_id
navigate_page(page_id, "https://miatrix.com/login")
wait_for(page_id, "networkidle" or selector for the login form)
```

Take a snapshot to understand the page layout:
```
take_snapshot(page_id)
```

Fill in the credentials and submit. Common selector patterns for login forms:
- Username: `input[type="email"]`, `input[name="username"]`, `input[name="email"]`, `#username`, `#email`
- Password: `input[type="password"]`
- Submit: `button[type="submit"]`, `input[type="submit"]`, `button:contains("Login")`, `button:contains("Sign in")`

```
fill(page_id, <username_selector>, MIATRIX_USER)
fill(page_id, "input[type='password']", MIATRIX_PASS)
click(page_id, <submit_selector>)
wait_for(page_id, "networkidle")
```

After clicking, verify login succeeded by checking the current URL — it should
no longer be `/login`. If still on the login page, or an error message is
visible in the snapshot, **stop immediately** and report:
> "Miatrix login failed — verify MIATRIX_USER and MIATRIX_PASS in OpenBao at
> `secret/data/users/joestump`"

Do not retry with modified credentials.

## Step 3: Extract the API key from the profile page

```
navigate_page(page_id, "https://miatrix.com/profile")
wait_for(page_id, "networkidle")
take_snapshot(page_id)
```

The API key is typically displayed as a visible text value or in a readonly
input. Try extracting it with `evaluate_script`:

```javascript
// Try multiple common patterns
(function() {
  const selectors = [
    'input[name*="api"]',
    'input[id*="api"]',
    'input[name*="key"]',
    'input[id*="key"]',
    'input[name*="token"]',
    '.api-key',
    '.apikey',
    '[data-apikey]',
    '[data-api-key]',
  ];
  for (const sel of selectors) {
    const el = document.querySelector(sel);
    if (el) return el.value || el.textContent.trim();
  }
  // Fall back: look for a code block or pre containing a plausible API key
  for (const el of document.querySelectorAll('code, pre, .token, .key')) {
    const text = el.textContent.trim();
    if (text.length > 16 && /^[a-zA-Z0-9_\-]+$/.test(text)) return text;
  }
  return null;
})()
```

If the script returns null, read the snapshot carefully — the key may be in
a button-revealed modal or a "copy" widget. Try `click`ing a "Show" or
"Reveal" button first, then re-evaluate.

Store the result as `NEW_API_KEY`. If you cannot extract it, take a screenshot
with `take_screenshot(page_id)` and report the page structure so the selector
can be updated.

Close the browser tab when done:
```
close_page(page_id)
```

## Step 4: Update Prowlarr's Miatrix indexer

Find the Miatrix indexer(s):
```bash
curl -s -H "X-Api-Key: $PROWLARR_KEY" \
  https://prowlarr.stump.rocks/api/v1/indexer \
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

For each Miatrix indexer found, GET the full config, update the API key field,
and PUT it back. The field is usually named `apiKey`, `key`, `api_key`, or
`passkey` inside the `fields` array. Use temp files to avoid shell pipeline
issues with Python env var injection:

```bash
# GET full config
curl -s -H "X-Api-Key: $PROWLARR_KEY" \
  https://prowlarr.stump.rocks/api/v1/indexer/$INDEXER_ID \
  > /tmp/prowlarr_indexer.json

# Patch the API key field
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
  https://prowlarr.stump.rocks/api/v1/indexer/$INDEXER_ID)

rm -f /tmp/prowlarr_indexer.json /tmp/prowlarr_patched.json
echo "Prowlarr responded: $HTTP_STATUS"
```

A `200` or `202` response means success. If the Python script exits with error
(field not found), print the available field names so the skill can be updated
with the correct field name.

## Step 5: Verify and report

Optionally test the updated indexer (use the per-indexer endpoint, not
`testall`, to avoid noise from other indexers):
```bash
curl -s -X POST \
  -H "X-Api-Key: $PROWLARR_KEY" \
  https://prowlarr.stump.rocks/api/v1/indexer/$INDEXER_ID/test
```

Report the outcome clearly:
```
✓ Retrieved new Miatrix API key from https://miatrix.com/profile
✓ Updated Prowlarr indexer "<name>" (ID: N)
  → Prowlarr responded: 200 OK
```

On any failure, state the exact step that failed and the error. Do not
include credential values in the output.
