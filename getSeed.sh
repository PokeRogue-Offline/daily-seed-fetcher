#!/bin/bash
set -e

. "$(dirname "$0")/lib.sh"

SEED=$(curl -sf \
  -H "Origin: https://pokerogue.net" \
  -H "Referer: https://pokerogue.net/" \
  "https://api.pokerogue.net/daily/seed")

if [ -z "$SEED" ]; then
  log_msg "ERROR: Failed to fetch daily seed."
  exit 1
fi

echo -n "$SEED" > /output/daily-seed.txt
log_msg "Fetched seed: $SEED"

curl -s -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/PokeRogue-Offline/pokerogue-offline/actions/workflows/fetch-seed.yaml/dispatches" \
  -d '{"ref":"main"}'
