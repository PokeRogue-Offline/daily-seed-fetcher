#!/bin/bash
set -e

. "$(dirname "$0")/lib.sh"

curl -s -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/PokeRogue-Offline/pokerogue-offline/actions/workflows/nightly-builds.yml/dispatches" \
  -d '{"ref":"main"}'

log_msg "Triggered nightly-builds.yml workflow."
