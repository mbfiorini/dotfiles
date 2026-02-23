#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

EXTENSIONS_FILE="$DOTFILES_DIR/scripts/manifests/gh-extensions.txt"

install_extensions() {
  if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    return 0
  fi

  local ext
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    [[ "$ext" =~ ^# ]] && continue

    if gh extension list 2>/dev/null | awk '{print $2}' | grep -Fxq "$ext"; then
      continue
    fi

    gh extension install "$ext"
  done < "$EXTENSIONS_FILE"
}

remove_extensions() {
  if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    return 0
  fi

  local ext
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    [[ "$ext" =~ ^# ]] && continue
    gh extension remove "$ext" >/dev/null 2>&1 || true
  done < "$EXTENSIONS_FILE"
}

if [[ "$MODE" == "install" ]]; then
  apt_install gh
  stow_module gh
  install_extensions
  log "Installed gh, applied dotfiles module, and installed extensions"
else
  remove_extensions
  unstow_module gh
  apt_remove gh
  log "Removed gh extensions, unstowed module, and removed gh"
fi
