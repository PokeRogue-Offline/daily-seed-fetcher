#!/bin/bash
set -e

. "$(dirname "$0")/lib.sh"

if [[ "$1" == "1" ]]; then
  log_msg "Force sync requested!";
fi

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

# Seed is now passed directly as a workflow_dispatch input — fetch-seed.yaml
# no longer fetches it itself over HTTP from this box, it just takes what we
# send it here over HTTPS. Escaped for safe embedding in the JSON body.
SEED_JSON=$(printf '%s' "$SEED" | sed 's/\\/\\\\/g; s/"/\\"/g')

curl -sf -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/PokeRogue-Offline/pokerogue-offline/actions/workflows/fetch-seed.yaml/dispatches" \
  -d "{\"ref\":\"main\",\"inputs\":{\"seed\":\"${SEED_JSON}\"}}"

send_ntfy "Updated Seed: ${SEED}" "PokeRogueOffline Seed Update"
