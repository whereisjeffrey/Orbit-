#!/bin/bash
#
# Auto-commit script for Orbit project
# Runs every 60 minutes at :00 via LaunchAgent
# Commits any uncommitted changes with timestamp
#

PROJECT_PATH="/Users/jeffrey/Desktop/Orbit"
cd "$PROJECT_PATH" || exit 1

# Check if there are any changes to commit
if git diff --quiet && git diff --cached --quiet; then
    # No changes, exit silently
    exit 0
fi

# There are changes - commit them
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
git add -A
git commit -m "auto-save: ${TIMESTAMP} Claude Code checkpoint"

# Log success
echo "[$(date)] Auto-committed changes in Orbit" >> "$PROJECT_PATH/.git-auto-commit.log"
