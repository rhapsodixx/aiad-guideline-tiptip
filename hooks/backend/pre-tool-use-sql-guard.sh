#!/bin/bash
# hooks/pre-tool-use-sql-guard.sh
# PreToolUse hook: blocks dangerous SQL patterns in bash commands

PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty')

# Regex patterns for dangerous SQL statements
if echo "$COMMAND" | grep -E -i -q '(DROP TABLE|TRUNCATE TABLE)'; then
    echo "Blocked: Destructive DROP/TRUNCATE queries are strictly prohibited without human intervention." >&2
    exit 2
fi

if echo "$COMMAND" | grep -E -i -q '\bDELETE FROM\b' && ! echo "$COMMAND" | grep -E -i -q '\bWHERE\b'; then
    echo "Blocked: DELETE FROM statement without a WHERE clause." >&2
    exit 2
fi

if echo "$COMMAND" | grep -E -i -q '\bUPDATE\b' && ! echo "$COMMAND" | grep -E -i -q '\bWHERE\b'; then
    echo "Blocked: UPDATE statement without a WHERE clause." >&2
    exit 2
fi

exit 0
