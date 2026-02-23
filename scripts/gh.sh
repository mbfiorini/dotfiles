#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

if [[ "$MODE" == "install" ]]; then
  apt_install gh
  stow_module gh
  log "Installed gh and applied dotfiles module"
else
  unstow_module gh
  apt_remove gh
  log "Removed gh and unstowed module"
fi
