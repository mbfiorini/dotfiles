#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

NVM_DIR="$HOME/.nvm"
NVM_COMMIT="977563e"
NODE_VERSION="22.22.0"

if [[ "$MODE" == "install" ]]; then
  apt_install ca-certificates curl

  ensure_git_clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  pin_git_commit "$NVM_DIR" "$NVM_COMMIT"

  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"

  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  nvm use default >/dev/null

  npm install -g @openai/codex@0.104.0
  npm install -g corepack@0.34.0

  log "Installed nvm/node and global npm packages"
else
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh"

    npm uninstall -g @openai/codex >/dev/null 2>&1 || true
    npm uninstall -g corepack >/dev/null 2>&1 || true

    nvm uninstall "$NODE_VERSION" >/dev/null 2>&1 || true
  fi

  rm -rf "$NVM_DIR"
  log "Removed nvm/node stack"
fi
