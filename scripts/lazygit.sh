#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

LAZYGIT_VERSION="0.59.0"
TARGET_BIN="/usr/local/bin/lazygit"

if [[ "$MODE" == "install" ]]; then
  apt_install curl

  tmp_dir="$(mktemp -d)"
  archive="$tmp_dir/lazygit.tar.gz"

  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o "$archive"
  tar -C "$tmp_dir" -xf "$archive"

  need_sudo
  ${SUDO} install -m 0755 "$tmp_dir/lazygit" "$TARGET_BIN"
  rm -rf "$tmp_dir"

  stow_module lazygit
  log "Installed lazygit and applied module"
else
  unstow_module lazygit

  need_sudo
  ${SUDO} rm -f "$TARGET_BIN"
  log "Removed lazygit and unstowed module"
fi
