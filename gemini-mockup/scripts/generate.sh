#!/usr/bin/env bash
#
# gemini-mockup: generate a UI mockup PNG via Gemini through LiteLLM.
#
# Usage:
#   generate.sh --prompt "<full prompt text>" --output "<absolute path>"
#                [--size 1536x1024] [--model gemini-3-pro-image-preview]
#                [--no-open]
#
# Reads OPENAI_BASE_URL and OPENAI_API_KEY from the environment. If those
# aren't set, re-execs itself under `bash -lc` so the user's login-shell rc
# files (.bashrc / .bash_profile / .zshrc / .profile) get a chance to set
# them — most LiteLLM users keep these in their shell rc rather than in
# the environment of every spawned process.
#
# Exit codes:
#   0   success
#   2   missing required argument
#   3   missing OPENAI_BASE_URL or OPENAI_API_KEY after env-load attempt
#   4   API call failed (curl error or non-2xx response)
#   5   response decode failed (no b64_json field, or base64 decode error)
#   6   unable to write output file

set -euo pipefail

# ------------------------------------------------------------------ args ---
PROMPT=""
OUTPUT=""
SIZE="1536x1024"
MODEL="gemini-3-pro-image-preview"
OPEN_AFTER=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prompt)   PROMPT="$2"; shift 2 ;;
        --output)   OUTPUT="$2"; shift 2 ;;
        --size)     SIZE="$2"; shift 2 ;;
        --model)    MODEL="$2"; shift 2 ;;
        --no-open)  OPEN_AFTER=0; shift ;;
        *)          echo "generate.sh: unknown argument: $1" >&2; exit 2 ;;
    esac
done

if [[ -z "$PROMPT" ]]; then
    echo "generate.sh: --prompt is required" >&2
    exit 2
fi
if [[ -z "$OUTPUT" ]]; then
    echo "generate.sh: --output is required" >&2
    exit 2
fi

# ----------------------------------------------------------------- env -----
# If the OpenAI-compatible LiteLLM env vars aren't set, the user probably
# has them in a login shell rc. Re-exec under `bash -lc` to get those.
if [[ -z "${OPENAI_BASE_URL:-}" || -z "${OPENAI_API_KEY:-}" ]]; then
    if [[ -z "${REDUIT_MOCKUP_ENV_RELOAD:-}" ]]; then
        # Use a flag to prevent infinite re-exec if the rc files don't set them.
        export REDUIT_MOCKUP_ENV_RELOAD=1
        # Re-quote args for the login shell.
        ARGS=()
        [[ -n "$PROMPT" ]] && ARGS+=(--prompt "$PROMPT")
        [[ -n "$OUTPUT" ]] && ARGS+=(--output "$OUTPUT")
        [[ -n "$SIZE" ]] && ARGS+=(--size "$SIZE")
        [[ -n "$MODEL" ]] && ARGS+=(--model "$MODEL")
        [[ "$OPEN_AFTER" -eq 0 ]] && ARGS+=(--no-open)
        exec bash -lc "$(printf '%q ' "$0" "${ARGS[@]}")"
    fi
    echo "generate.sh: OPENAI_BASE_URL and OPENAI_API_KEY are not set" >&2
    echo "  These typically live in your login shell rc (.bashrc / .zshrc)." >&2
    echo "  Confirm: bash -lc 'echo \$OPENAI_BASE_URL'" >&2
    exit 3
fi

# Sanity check the URL — strip trailing slash to avoid // in the path.
BASE_URL="${OPENAI_BASE_URL%/}"

# -------------------------------------------------------------- output dir -
OUTPUT_DIR="$(dirname "$OUTPUT")"
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# --------------------------------------------------------------- API call --
# Build the JSON payload. Use python3 for safe JSON encoding of the prompt
# (bash escaping inside JSON is error-prone for multi-line prompts with
# quotes).
PAYLOAD=$(python3 <<PY
import json, sys
print(json.dumps({
    "model": "$MODEL",
    "prompt": $(printf '%s' "$PROMPT" | python3 -c "import sys, json; print(json.dumps(sys.stdin.read()))"),
    "n": 1,
    "size": "$SIZE",
    "response_format": "b64_json",
}))
PY
)

# Make the request. Capture body and HTTP status separately so we can give
# a clear diagnostic on failure.
TMP_RESPONSE=$(mktemp)
trap 'rm -f "$TMP_RESPONSE"' EXIT

HTTP_STATUS=$(
    curl -sS \
        -o "$TMP_RESPONSE" \
        -w "%{http_code}" \
        -X POST "$BASE_URL/v1/images/generations" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        --data "$PAYLOAD" \
    || echo "curl-failed"
)

if [[ "$HTTP_STATUS" == "curl-failed" ]]; then
    echo "generate.sh: curl failed to reach $BASE_URL/v1/images/generations" >&2
    exit 4
fi

if [[ "$HTTP_STATUS" -lt 200 || "$HTTP_STATUS" -ge 300 ]]; then
    echo "generate.sh: API returned HTTP $HTTP_STATUS" >&2
    echo "Response body (first 1KB):" >&2
    head -c 1024 "$TMP_RESPONSE" >&2
    echo >&2
    exit 4
fi

# ------------------------------------------------------------- decode + save
python3 <<PY
import sys, json, base64, os
try:
    with open("$TMP_RESPONSE") as f:
        data = json.load(f)
except Exception as e:
    print(f"generate.sh: failed to parse response JSON: {e}", file=sys.stderr)
    sys.exit(5)

try:
    img_b64 = data["data"][0]["b64_json"]
except (KeyError, IndexError) as e:
    print(f"generate.sh: response missing data[0].b64_json: {e}", file=sys.stderr)
    print(f"  Top-level keys: {list(data.keys())}", file=sys.stderr)
    sys.exit(5)

try:
    img_bytes = base64.b64decode(img_b64)
except Exception as e:
    print(f"generate.sh: base64 decode failed: {e}", file=sys.stderr)
    sys.exit(5)

try:
    with open("$OUTPUT", "wb") as f:
        f.write(img_bytes)
except OSError as e:
    print(f"generate.sh: failed to write $OUTPUT: {e}", file=sys.stderr)
    sys.exit(6)

print(f"Saved {len(img_bytes)} bytes to $OUTPUT")
PY

# ---------------------------------------------------------------- open it --
if [[ "$OPEN_AFTER" -eq 1 ]]; then
    PLATFORM=$(uname -s)
    case "$PLATFORM" in
        Linux)
            if command -v xdg-open >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
                xdg-open "$OUTPUT" >/dev/null 2>&1 &
            fi
            ;;
        Darwin)
            open "$OUTPUT" >/dev/null 2>&1 &
            ;;
    esac
fi

echo "$OUTPUT"
