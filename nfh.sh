#!/bin/bash
# nfh — Quick-launch the Self-Improvement Loop
# Usage:
#   ./nfh                  # Default: 15-minute run
#   ./nfh cycles=12        # Run exactly 12 cycles
#   ./nfh time=900         # Run for 15 minutes
#   ./nfh cycles=12 time=7200  # 12 cycles or 2 hours, whichever comes first

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

LOOP_DURATION=""
LOOP_MAX_CYCLES=""

for arg in "$@"; do
    case "$arg" in
        cycles=*)
            LOOP_MAX_CYCLES="${arg#cycles=}"
            ;;
        time=*)
            LOOP_DURATION="${arg#time=}"
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: ./nfh [cycles=N] [time=N]"
            exit 1
            ;;
    esac
done

# Set defaults if not specified
LOOP_DURATION=${LOOP_DURATION:-900}  # 15 minutes

echo "╔════════════════════════════════════════╗"
echo "║   NFH Self-Improvement Loop           ║"
echo "╠════════════════════════════════════════╣"
echo "║  Duration: ${LOOP_DURATION}s ($(( LOOP_DURATION / 60 )) min)          ║"
if [ -n "$LOOP_MAX_CYCLES" ] && [ "$LOOP_MAX_CYCLES" -gt 0 ]; then
    echo "║  Max cycles: ${LOOP_MAX_CYCLES}                       ║"
fi
echo "╚════════════════════════════════════════╝"
echo ""

export LOOP_DURATION
export LOOP_MAX_CYCLES
exec "$SCRIPT_DIR/orchestrate.sh"
