#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

if [[ "$MODE" == "install" ]]; then
  apt_install git
  stow_module git
  log "Installed git and applied dotfiles module"
else
  unstow_module git
  apt_remove git
  log "Removed git and unstowed module"
fi
