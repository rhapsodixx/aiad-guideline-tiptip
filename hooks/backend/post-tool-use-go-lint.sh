#!/bin/bash
# hooks/post-tool-use-go-lint.sh
# PostToolUse hook: runs go vet and golangci-lint after any Go file write

# Read stdin JSON
PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# Check if it's a Go file
if [[ ! "$FILE_PATH" == *.go ]]; then
    exit 0
fi

DIR=$(dirname "$FILE_PATH")

# Run vetting tools and capture output
VET_OUT=$(go vet "./$DIR/..." 2>&1)
LINT_OUT=$(golangci-lint run "./$DIR/..." 2>&1)

if [ -n "$VET_OUT" ] || [ -n "$LINT_OUT" ]; then
    # Return errors to Claude to self-correct
    jq -n \
      --arg vet "$VET_OUT" \
      --arg lint "$LINT_OUT" \
      '{
         decision: "block",
         reason: "Linting failed. Please fix the following issues.",
         hookSpecificOutput: {
           hookEventName: "PostToolUse",
           additionalContext: ($vet + "\n" + $lint)
         }
       }'
    exit 0
fi

exit 0
