#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"

install_plugin() {
  local repo="$1"
  local name="$2"
  local commit="$3"
  local path="$TMUX_PLUGIN_DIR/$name"
  ensure_git_clone "$repo" "$path"
  pin_git_commit "$path" "$commit"
}

if [[ "$MODE" == "install" ]]; then
  apt_install tmux

  mkdir -p "$TMUX_PLUGIN_DIR"
  install_plugin https://github.com/tmux-plugins/tpm tpm 99469c4
  install_plugin https://github.com/tmux-plugins/tmux-sensible tmux-sensible 25cb91f
  install_plugin https://github.com/christoomey/vim-tmux-navigator vim-tmux-navigator e41c431
  install_plugin https://github.com/dreamsofcode-io/catppuccin-tmux catppuccin-tmux b4e0715
  install_plugin https://github.com/tmux-plugins/tmux-yank tmux-yank acfd36e

  stow_module tmux
  log "Installed tmux + plugins and applied module"
else
  unstow_module tmux

  rm -rf "$TMUX_PLUGIN_DIR/tpm"
  rm -rf "$TMUX_PLUGIN_DIR/tmux-sensible"
  rm -rf "$TMUX_PLUGIN_DIR/vim-tmux-navigator"
  rm -rf "$TMUX_PLUGIN_DIR/catppuccin-tmux"
  rm -rf "$TMUX_PLUGIN_DIR/tmux-yank"

  apt_remove tmux
  log "Removed tmux stack and unstowed module"
fi
