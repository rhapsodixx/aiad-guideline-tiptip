#!/bin/bash
# hooks/stop-session-summary.sh
# Stop hook: appends a session summary to .claude-session-log.md

PAYLOAD=$(cat)
REASON=$(echo "$PAYLOAD" | jq -r '.last_assistant_message // "Session stopped."')
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cat <<EOF >> .claude-session-log.md
## Session: $TIMESTAMP
**Summary:**
$REASON
---
EOF

exit 0
