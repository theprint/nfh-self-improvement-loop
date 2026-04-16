#!/bin/bash
# hard-blocks.sh — Hard enforcement of NFH invariants
# These checks are MANDATORY. No exceptions. No override.
# Called by the orchestrator BEFORE and AFTER each cycle.
# Exit 1 = hard stop. The loop dies.

set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
STATE_FILE="$WORKSPACE/projects/self-improvement/state.json"

echo "=== HARD BLOCKS ==="

# === BLOCK 1: Single change enforcement ===
# After generator commits, check diff size against main.
# More than 3 files changed = batch operation = FORBIDDEN.
DIFF_COUNT=$(cd "$WORKSPACE" && git diff --name-only main..self-improvement-dev 2>/dev/null | wc -l | tr -d ' ')
if [ "$DIFF_COUNT" -gt 3 ]; then
    echo "BLOCKED: $DIFF_COUNT files changed (max 3). Batch operations are forbidden."
    echo "Files changed:"
    cd "$WORKSPACE" && git diff --name-only main..self-improvement-dev
    echo "RUN: git reset --hard main"
    cd "$WORKSPACE" && git checkout self-improvement-dev && git reset --hard main
    exit 1
fi
echo "✓ Single change: $DIFF_COUNT file(s) changed"

# === BLOCK 2: Evaluator session must exist and differ from generator ===
GENERATOR=$(jq -r '.generator_session_id // empty' < "$STATE_FILE" 2>/dev/null)
EVALUATOR=$(jq -r '.evaluator_session_id // empty' < "$STATE_FILE" 2>/dev/null)

if [ -z "$EVALUATOR" ]; then
    echo "BLOCKED: No evaluator_session_id in state.json. Evaluation never ran."
    exit 1
fi

if [ -z "$GENERATOR" ]; then
    echo "BLOCKED: No generator_session_id in state.json."
    exit 1
fi

if [ "$GENERATOR" = "$EVALUATOR" ]; then
    echo "BLOCKED: Generator and evaluator are the same session ($GENERATOR)"
    exit 1
fi
echo "✓ Separate agents: generator=$GENERATOR evaluator=$EVALUATOR"

# === BLOCK 3: Approval must be recorded ===
APPROVED=$(jq -r '.last_verdict // empty' < "$STATE_FILE" 2>/dev/null)
if [ -z "$APPROVED" ]; then
    echo "BLOCKED: No last_verdict in state.json. Was evaluation actually performed?"
    exit 1
fi

if [ "$APPROVED" != "APPROVE" ]; then
    echo "BLOCKED: Last verdict was '$APPROVED', not APPROVE. Merge forbidden."
    exit 1
fi
echo "✓ Verdict recorded: $APPROVED"

echo "=== HARD BLOCKS PASSED ==="
exit 0
