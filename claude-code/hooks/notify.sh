#!/bin/bash
# Claude Code notification hook
# Usage: notify.sh <subtitle> <message> <sound>
# Reads cwd from stdin JSON to identify the project
# Runs terminal-notifier in background to avoid blocking hooks

SUBTITLE="${1:-通知}"
MESSAGE="${2:-Claude Code}"
SOUND="${3:-default}"

# Read stdin JSON and extract cwd
INPUT=$(cat)
CWD=$(echo "$INPUT" | /opt/homebrew/bin/jq -r '.cwd // empty' 2>/dev/null)

# Extract project name from cwd (last directory component)
if [ -n "$CWD" ]; then
  PROJECT_NAME=$(basename "$CWD")
else
  PROJECT_NAME="unknown"
fi

/opt/homebrew/bin/terminal-notifier \
  -title "Claude Code [$PROJECT_NAME]" \
  -subtitle "$SUBTITLE" \
  -message "$MESSAGE" \
  -sound "$SOUND" \
  -timeout 5 &

exit 0
