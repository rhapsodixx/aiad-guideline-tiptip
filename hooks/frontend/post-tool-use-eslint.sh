#!/bin/bash
# hooks/post-tool-use-eslint.sh
# PostToolUse hook: runs eslint --fix after any TS/JS/TSX/JSX file write

PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx)
        LINT_OUT=$(npx eslint --fix "$FILE_PATH" 2>&1)
        STATUS=$?
        
        if [ $STATUS -ne 0 ]; then
            jq -n \
              --arg lint "$LINT_OUT" \
              '{
                 decision: "block",
                 reason: "ESLint failed after auto-fix attempts.",
                 hookSpecificOutput: {
                   hookEventName: "PostToolUse",
                   additionalContext: $lint
                 }
               }'
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

exit 0
