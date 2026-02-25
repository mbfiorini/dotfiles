#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

EXTENSIONS_FILE="$DOTFILES_DIR/scripts/manifests/gh-extensions.txt"

install_extensions() {
  if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    return 0
  fi

  if ! gh auth status >/dev/null 2>&1; then
    log "gh is not authenticated yet; skipping extension install. Run 'gh auth login' and then './scripts/gh.sh'."
    return 0
  fi

  local had_failures=0
  local ext
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    [[ "$ext" =~ ^# ]] && continue

    if gh extension list 2>/dev/null | awk '{print $2}' | grep -Fxq "$ext"; then
      continue
    fi

    if ! gh extension install "$ext"; then
      echo "[gh.sh] Warning: failed to install extension '$ext' (continuing)." >&2
      had_failures=1
    fi
  done < "$EXTENSIONS_FILE"

  if [[ "$had_failures" -ne 0 ]]; then
    log "Some gh extensions failed to install. Continue bootstrap, then rerun './scripts/gh.sh' after auth/network is fixed."
  fi
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
