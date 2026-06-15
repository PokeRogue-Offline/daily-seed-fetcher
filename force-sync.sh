#!/bin/bash
# Manually trigger the daily seed fetch + workflow dispatch right now,
# streaming the output live.
#
# Usage: ./force-sync.sh [container-name]

set -e

. "$(dirname "$0")/lib.sh"

CONTAINER="${1:-daily-seed-fetcher}"

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" >/dev/null 2>&1; then
  log_msg "ERROR: Container '$CONTAINER' is not running."
  exit 1
fi

log_msg "Triggering manual sync in '$CONTAINER'..."
docker exec "$CONTAINER" sh -c '/usr/local/bin/getSeed.sh 2>&1 | tee /proc/1/fd/1'
log_msg "Done."
