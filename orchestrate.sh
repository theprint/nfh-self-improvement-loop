#!/bin/bash
# Self-Improvement Loop — Orchestrator Script

set -e

WORKSPACE="$HOME/.openclaw/workspace"
PROJECT_DIR="$WORKSPACE/projects/self-improvement"
STATE_FILE="$PROJECT_DIR/state.json"

# Set timer defaults if not provided by caller
export LOOP_START_TIME=${LOOP_START_TIME:-$(date +%s)}
export LOOP_DURATION=${LOOP_DURATION:-900}  # 15 minutes default
export LOOP_MAX_CYCLES=${LOOP_MAX_CYCLES:-0}  # 0 = unlimited

# === PRE-FLIGHT: Run ALL checks ===
if [ -f "$PROJECT_DIR/preflight.sh" ]; then
    "$PROJECT_DIR/preflight.sh" || exit 1
else
    echo "ERROR: preflight.sh not found. Cannot proceed."
    exit 1
fi

# Verify separate agents (critical guardrail)
if [ -f "$PROJECT_DIR/verify-agents.sh" ]; then
    "$PROJECT_DIR/verify-agents.sh" || exit 1
fi

cd "$WORKSPACE"

# Rotate mode
CURRENT_MODE=$(jq -r '.last_cycle_type // "refactor"' < "$STATE_FILE" 2>/dev/null || echo "refactor")
case "$CURRENT_MODE" in
    "refactor") MODE="discover" ;;
    "discover") MODE="combine" ;;
    "combine") MODE="refactor" ;;
    *) MODE="refactor" ;;
esac

RUN_COUNT=$(jq -r '.run_count // 0' < "$STATE_FILE" 2>/dev/null || echo "0")
echo "✓ Mode: $MODE (run #$((RUN_COUNT + 1)))"

# Output
echo "branch: self-improvement-dev"
echo "mode: $MODE"
