#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

PACKAGES=(
  fonts-freefont-ttf
  fonts-ipafont-gothic
  fonts-liberation
  fonts-noto-color-emoji
  fonts-tlwg-loma-otf
  fonts-unifont
  fonts-wqy-zenhei
  xfonts-cyrillic
  xfonts-scalable
)

if [[ "$MODE" == "install" ]]; then
  apt_install "${PACKAGES[@]}"
  log "Installed font packages"
else
  apt_remove "${PACKAGES[@]}"
  log "Uninstalled font packages"
fi
