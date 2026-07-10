#!/bin/bash
set -e

. "$(dirname "$0")/lib.sh"

UPSTREAM_URL="https://github.com/pagefaultgames/pokerogue.git"
UPSTREAM_BRANCH="main"
REPO_DIR="/output/pkr-upstream-repo"
STATE_FILE="/output/last-pkr-version.txt"
VERSION_REGEX='^1\.[0-9]+\.[0-9]+\.[0-9]+$'

# --- One-time sparse clone setup ---
if [ ! -d "${REPO_DIR}/.git" ]; then
  log_msg "Sparse clone not found, setting up at ${REPO_DIR}"
  rm -rf "${REPO_DIR}"
  git clone --depth 1 --filter=blob:none --sparse "${UPSTREAM_URL}" "${REPO_DIR}"
  (
    cd "${REPO_DIR}"
    git sparse-checkout init --no-cone
    git sparse-checkout set package.json
  )
  log_msg "Sparse clone set up successfully."
fi

# --- Fetch latest package.json from upstream ---
cd "${REPO_DIR}"
git fetch --depth 1 origin "${UPSTREAM_BRANCH}"
git checkout FETCH_HEAD -- package.json

CURRENT_VERSION=$(jq -r '.version' package.json 2>/dev/null || true)

if [ -z "$CURRENT_VERSION" ] || [ "$CURRENT_VERSION" = "null" ]; then
  log_msg "ERROR: could not parse .version from package.json."
  exit 1
fi

if ! echo "$CURRENT_VERSION" | grep -qE "$VERSION_REGEX"; then
  log_msg "WARNING: version '${CURRENT_VERSION}' does not match expected format 1.NN.NN.NN. Skipping."
  exit 0
fi

# --- Compare against last-known version ---
LAST_VERSION=""
if [ -f "$STATE_FILE" ]; then
  LAST_VERSION=$(cat "$STATE_FILE")
fi

if [ "$CURRENT_VERSION" = "$LAST_VERSION" ]; then
  exit 0
fi

log_msg "Version change detected: '${LAST_VERSION:-<none>}' -> '${CURRENT_VERSION}'"

# --- Trigger the Create Release workflow ---
curl -s -X POST \
  -H "Authorization: Bearer ${GH_PAT}" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/PokeRogue-Offline/pokerogue-offline/actions/workflows/create-release.yaml/dispatches" \
  -d '{"ref":"main"}'

echo -n "$CURRENT_VERSION" > "$STATE_FILE"
log_msg "Triggered create-release.yaml for version ${CURRENT_VERSION}."
