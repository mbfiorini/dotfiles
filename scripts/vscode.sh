#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

if [[ "$MODE" == "install" ]]; then
  stow_module vscode
  log "Applied VS Code user config module (extensions/settings are expected from VS Code Settings Sync)"
else
  unstow_module vscode
  log "Unstowed VS Code user config module"
fi
