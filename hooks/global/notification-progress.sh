#!/bin/bash
# hooks/notification-progress.sh
# Notification hook: surfaces Claude's progress notifications in terminal

PAYLOAD=$(cat)
MESSAGE=$(echo "$PAYLOAD" | jq -r '.message // "Update"')

TIMESTAMP=$(date +"%H:%M:%S")
echo "[$TIMESTAMP] Claude progress: $MESSAGE" >&2

exit 0
