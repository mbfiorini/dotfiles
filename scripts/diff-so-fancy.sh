#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

DIFF_SO_FANCY_VERSION="1.4.14"
NVM_DIR="$HOME/.nvm"
NPM_PREFIX="$HOME/.local"
NPM_REGISTRY="https://registry.npmjs.org/"

load_node() {
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    echo "nvm is required. Run scripts/node.sh first." >&2
    exit 1
  fi

  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
  nvm use default >/dev/null
}

if [[ "$MODE" == "install" ]]; then
  load_node
  mkdir -p "$NPM_PREFIX/bin"
  npm install --global --prefix "$NPM_PREFIX" --registry "$NPM_REGISTRY" \
    "diff-so-fancy@${DIFF_SO_FANCY_VERSION}"
  log "Installed diff-so-fancy ${DIFF_SO_FANCY_VERSION} in $NPM_PREFIX/bin"
else
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    load_node
    npm uninstall --global --prefix "$NPM_PREFIX" --registry "$NPM_REGISTRY" \
      diff-so-fancy >/dev/null 2>&1 || true
  fi
  rm -f "$NPM_PREFIX/bin/diff-so-fancy"
  log "Removed diff-so-fancy"
fi
