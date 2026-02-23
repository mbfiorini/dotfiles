#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
LEGACY_OMZ_DIR="$HOME/.oh-my-zsh"
LEGACY_CATPPUCCIN_DIR="$HOME/.config/catppuccin/zsh-syntax-highlighting"

if [[ "$MODE" == "install" ]]; then
  apt_install zsh xclip zoxide git

  ensure_git_clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

  stow_module zsh

  log "Installed zsh + zinit plugin manager and applied module"
  log "Optional: set zsh as default shell with: chsh -s $(command -v zsh)"
else
  unstow_module zsh

  rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/zinit"
  rm -rf "$LEGACY_CATPPUCCIN_DIR"
  rm -rf "$LEGACY_OMZ_DIR"

  apt_remove zsh
  log "Removed zsh stack (zinit + legacy oh-my-zsh leftovers) and unstowed module"
fi
