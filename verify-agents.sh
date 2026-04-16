#!/bin/bash
# verify-agents.sh — Ensures Generator and Evaluator are different sessions
# Usage: ./verify-agents.sh
# Exits 1 if same session, 0 if different

set -e

STATE_FILE="$HOME/.openclaw/workspace/projects/self-improvement/state.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "ERROR: state.json not found"
    exit 1
fi

GENERATOR_SESSION=$(jq -r '.generator_session_id // empty' < "$STATE_FILE")
EVALUATOR_SESSION=$(jq -r '.evaluator_session_id // empty' < "$STATE_FILE")

if [ -z "$GENERATOR_SESSION" ] || [ -z "$EVALUATOR_SESSION" ]; then
    echo "ERROR: Missing session IDs. Generator and Evaluator must be spawned via sessions_spawn."
    echo "  generator_session_id: $GENERATOR_SESSION"
    echo "  evaluator_session_id: $EVALUATOR_SESSION"
    exit 1
fi

if [ "$GENERATOR_SESSION" = "$EVALUATOR_SESSION" ]; then
    echo "ERROR: Generator and Evaluator have the SAME session ID ($GENERATOR_SESSION)"
    echo "CRITICAL FAILURE: Same agent for generation and evaluation is forbidden."
    echo "This system requires separate agents via sessions_spawn with different agentIds."
    exit 1
fi

echo "✓ Verified: Different sessions (generator: $GENERATOR_SESSION, evaluator: $EVALUATOR_SESSION)"
exit 0
