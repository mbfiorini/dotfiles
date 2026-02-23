#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

if [[ "$MODE" == "install" ]]; then
  apt_install python3-pip python3-venv pipx

  if command -v pipx >/dev/null 2>&1; then
    pipx install --force tldr==3.4.4
  fi

  log "Installed python tooling and pipx package(s)"
else
  if command -v pipx >/dev/null 2>&1; then
    pipx uninstall tldr >/dev/null 2>&1 || true
  fi

  apt_remove python3-pip python3-venv pipx
  log "Removed python tooling and pipx package(s)"
fi
