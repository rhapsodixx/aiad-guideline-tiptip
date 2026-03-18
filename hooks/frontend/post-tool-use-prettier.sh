#!/bin/bash
# hooks/post-tool-use-prettier.sh
# PostToolUse hook: runs prettier --write after frontend file writes

PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.css|*.json|*.md)
        # Suppress stdout, only capture stderr
        ERR_OUT=$(npx prettier --write "$FILE_PATH" 2>&1 > /dev/null)
        STATUS=$?
        
        if [ $STATUS -ne 0 ]; then
            jq -n \
              --arg err "$ERR_OUT" \
              '{
                 decision: "block",
                 reason: "Prettier tool crashed or failed.",
                 hookSpecificOutput: {
                   hookEventName: "PostToolUse",
                   additionalContext: $err
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
