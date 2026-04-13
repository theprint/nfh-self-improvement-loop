#!/bin/bash
# Self-Improvement Loop — Pre-flight Checks
# Verifies ALL requirements before the loop can start.
# Exit 1 on any failure. No half-measures.

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
PROJECT_DIR="$WORKSPACE/projects/self-improvement"
STATE_FILE="$PROJECT_DIR/state.json"
ERRORS=0

echo "=== Self-Improvement Pre-flight ==="

# 1. Check timer is set
if [ -z "${LOOP_START_TIME:-}" ]; then
    echo "ERROR: LOOP_START_TIME not set. Timer is mandatory."
    ERRORS=$((ERRORS + 1))
else
    NOW=$(date +%s)
    ELAPSED=$(( NOW - LOOP_START_TIME ))
    echo "✓ Timer set. Elapsed: ${ELAPSED}s"
fi

# 2. Check loop duration is set
if [ -z "${LOOP_DURATION:-}" ]; then
    echo "ERROR: LOOP_DURATION not set (seconds). Required to know when to stop."
    ERRORS=$((ERRORS + 1))
else
    echo "✓ Duration: ${LOOP_DURATION}s ($(( LOOP_DURATION / 60 )) minutes)"
fi

# 3. Check we're on a fresh dev branch
BRANCH=$(cd "$WORKSPACE" && git branch --show-current)
if [ "$BRANCH" != "self-improvement-dev" ]; then
    echo "ERROR: Not on self-improvement-dev branch (currently: $BRANCH)"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ On dev branch: $BRANCH"
fi

# 4. Check dev branch was created fresh (no stale commits ahead of main)
AHEAD=$(cd "$WORKSPACE" && git rev-list main..self-improvement-dev --count 2>/dev/null || echo "0")
if [ "$AHEAD" -ne 0 ]; then
    echo "ERROR: Dev branch has $AHEAD stale commits ahead of main. Must be fresh."
    ERRORS=$((ERRORS + 1))
else
    echo "✓ Dev branch is fresh (0 commits ahead of main)"
fi

# 5. Check state.json exists
if [ ! -f "$STATE_FILE" ]; then
    echo "ERROR: state.json not found at $STATE_FILE"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ state.json exists"
fi

# 6. Check verify-agents.sh exists and is executable
if [ ! -x "$PROJECT_DIR/verify-agents.sh" ]; then
    echo "ERROR: verify-agents.sh not found or not executable"
    ERRORS=$((ERRORS + 1))
else
    echo "✓ verify-agents.sh exists and executable"
fi

# 7. Check generator-prompt.md and evaluator-prompt.md exist
for f in generator-prompt.md evaluator-prompt.md; do
    if [ ! -f "$PROJECT_DIR/$f" ]; then
        echo "ERROR: $f not found"
        ERRORS=$((ERRORS + 1))
    else
        echo "✓ $f exists"
    fi
done

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "✓ All pre-flight checks passed"
    exit 0
else
    echo "FAILED: $ERRORS error(s). Fix before running."
    exit 1
fi
