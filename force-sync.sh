#!/bin/bash
# Manually trigger the daily seed fetch + workflow dispatch right now,
# streaming the output live.
#
# Usage: ./force-sync.sh [container-name]

set -e

CONTAINER="${1:-daily-seed-fetcher}"

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" >/dev/null 2>&1; then
  echo "ERROR: Container '$CONTAINER' is not running." >&2
  exit 1
fi

echo "Triggering manual sync in '$CONTAINER'..."
echo "---"
docker exec "$CONTAINER" sh -c '/usr/local/bin/getSeed.sh 2>&1 | tee /proc/1/fd/1'
echo "---"
echo "Done."
