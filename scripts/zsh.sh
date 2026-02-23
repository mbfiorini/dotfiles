#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_COMMIT="88659ed"

AUTO_DIR="$OMZ_DIR/custom/plugins/zsh-autosuggestions"
AUTO_COMMIT="85919cd"

SYNTAX_DIR="$OMZ_DIR/custom/plugins/zsh-syntax-highlighting"
SYNTAX_COMMIT="5eb677b"

P10K_DIR="$OMZ_DIR/custom/themes/powerlevel10k"
P10K_COMMIT="efc9ddd"

CATPPUCCIN_DIR="$HOME/.config/catppuccin/zsh-syntax-highlighting"
CATPPUCCIN_COMMIT="7926c3d"

if [[ "$MODE" == "install" ]]; then
  apt_install zsh xclip zoxide

  ensure_git_clone https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
  pin_git_commit "$OMZ_DIR" "$OMZ_COMMIT"

  ensure_git_clone https://github.com/zsh-users/zsh-autosuggestions "$AUTO_DIR"
  pin_git_commit "$AUTO_DIR" "$AUTO_COMMIT"

  ensure_git_clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_DIR"
  pin_git_commit "$SYNTAX_DIR" "$SYNTAX_COMMIT"

  ensure_git_clone https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  pin_git_commit "$P10K_DIR" "$P10K_COMMIT"

  ensure_git_clone https://github.com/catppuccin/zsh-syntax-highlighting.git "$CATPPUCCIN_DIR"
  pin_git_commit "$CATPPUCCIN_DIR" "$CATPPUCCIN_COMMIT"

  stow_module zsh

  log "Installed zsh + Oh My Zsh + plugins/themes and applied module"
  log "Optional: set zsh as default shell with: chsh -s $(command -v zsh)"
else
  unstow_module zsh

  rm -rf "$CATPPUCCIN_DIR"
  rm -rf "$AUTO_DIR" "$SYNTAX_DIR" "$P10K_DIR"
  rm -rf "$OMZ_DIR"

  apt_remove zsh
  log "Removed zsh stack and unstowed module"
fi
