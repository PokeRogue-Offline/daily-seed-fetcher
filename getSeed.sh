#!/bin/bash
set -e

SEED=$(curl -sf \
  -H "Origin: https://pokerogue.net" \
  -H "Referer: https://pokerogue.net/" \
  "https://api.pokerogue.net/daily/seed")

if [ -z "$SEED" ]; then
  echo "ERROR: Failed to fetch daily seed."
  exit 1
fi

echo -n "$SEED" > /output/daily-seed.txt
echo "Fetched seed: $SEED"

curl -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/PokeRogue-Offline/pokerogue-offline/actions/workflows/fetch-seed.yaml/dispatches" \
  -d '{"ref":"main"}'
