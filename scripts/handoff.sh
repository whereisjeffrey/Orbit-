#!/bin/bash
# handoff.sh — Run at end of any agent session or auto-triggered by heartbeat
# Usage: bash scripts/handoff.sh "reason"
# e.g.:  bash scripts/handoff.sh "Nigel session end"
#        bash scripts/handoff.sh "auto-heartbeat"
#        bash scripts/handoff.sh "Antigravity session end"

REASON="${1:-manual}"
DATE=$(date '+%Y-%m-%d %H:%M')
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

# ── 1. Check if there's anything to commit ──────────────────────────────
CHANGES=$(git status --short 2>/dev/null)
if [ -z "$CHANGES" ]; then
    echo "[handoff] No uncommitted changes. Nothing to do."
    exit 0
fi

# ── 2. Append to WORK_LOG.md ─────────────────────────────────────────────
CHANGED_FILES=$(git status --short | awk '{print $2}' | tr '\n' ' ')
cat >> WORK_LOG.md << LOGENTRY

## $DATE — Auto-handoff ($REASON)
### Changed (uncommitted)
$CHANGES
### Files
$CHANGED_FILES
LOGENTRY

echo "[handoff] Appended to WORK_LOG.md"

# ── 3. Update HANDOFF.md timestamp ──────────────────────────────────────
# Just update the date line so agents know it's current
sed -i '' "s/^Date: .*/Date: $DATE/" HANDOFF.md 2>/dev/null
echo "[handoff] Updated HANDOFF.md timestamp"

# ── 4. Commit everything ─────────────────────────────────────────────────
git add -A
git commit -m "chore: auto-handoff [$REASON] — $DATE"
echo "[handoff] Committed."
