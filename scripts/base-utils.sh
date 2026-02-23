#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

PACKAGES=(
  apt-transport-https
  bat
  build-essential
  ca-certificates
  curl
  eza
  fd-find
  fzf
  gnupg
  jq
  lsb-release
  openssh-client
  ripgrep
  software-properties-common
  stow
  unzip
  wget
  xclip
  zip
  zoxide
)

if [[ "$MODE" == "install" ]]; then
  apt_install "${PACKAGES[@]}"

  mkdir -p "$HOME/.local/bin"
  if command -v batcat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
  if command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  log "Installed base utility packages"
else
  rm -f "$HOME/.local/bin/bat" "$HOME/.local/bin/fd"
  apt_remove "${PACKAGES[@]}"
  log "Uninstalled base utility packages"
fi
