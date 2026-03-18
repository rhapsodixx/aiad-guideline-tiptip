#!/bin/bash
# hooks/pre-tool-use-secret-guard.sh
# PreToolUse hook: blocks file writes containing secret patterns

PAYLOAD=$(cat)
CONTENT=$(echo "$PAYLOAD" | jq -r '.tool_input.content // empty')

# AWS keys
if echo "$CONTENT" | grep -E -q 'AKIA[0-9A-Z]{16}'; then
    echo "Blocked: Detected potential AWS Access Key ID." >&2
    exit 2
fi

# Private keys
if echo "$CONTENT" | grep -E -q '-----BEGIN.*PRIVATE KEY-----'; then
    echo "Blocked: Detected Private Key block." >&2
    exit 2
fi

# Common DB credential leak inside URIs like postgres://user:password@
if echo "$CONTENT" | grep -E -q ':\/\/\w+:\w+@'; then
    echo "Blocked: Detected connection string with embedded password." >&2
    exit 2
fi

# Generic API keys
if echo "$CONTENT" | grep -E -i -q '(api_key|apikey|secret_key)\s*=\s*["'"'"'][^"'"'"']{16,}'; then
    echo "Blocked: Detected hardcoded API key or secret." >&2
    exit 2
fi

exit 0
