#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

log() {
  printf '[%s] %s\n' "$(basename "$0")" "$*"
}

parse_mode() {
  MODE="install"
  if [[ "${1:-}" == "-U" ]]; then
    MODE="uninstall"
    shift
  fi

  if [[ $# -ne 0 ]]; then
    echo "Usage: $(basename "$0") [-U]" >&2
    exit 1
  fi
}

need_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
  else
    SUDO="sudo"
  fi
}

apt_update() {
  need_sudo
  if [[ ! -f /tmp/dotfiles-apt-updated.flag ]]; then
    ${SUDO} apt-get update
    touch /tmp/dotfiles-apt-updated.flag
  fi
}

apt_install() {
  if [[ $# -eq 0 ]]; then
    return 0
  fi
  apt_update
  need_sudo
  DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get install -y "$@"
}

apt_remove() {
  if [[ $# -eq 0 ]]; then
    return 0
  fi

  need_sudo
  local installed=()
  local pkg
  for pkg in "$@"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      installed+=("$pkg")
    fi
  done

  if [[ ${#installed[@]} -eq 0 ]]; then
    return 0
  fi

  DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get remove -y "${installed[@]}"
}

ensure_git_clone() {
  local repo="$1"
  local dst="$2"

  if [[ -d "$dst/.git" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  git clone "$repo" "$dst"
}

pin_git_commit() {
  local dst="$1"
  local commit="$2"

  if [[ ! -d "$dst/.git" ]]; then
    return 0
  fi

  git -C "$dst" fetch --all --tags --prune >/dev/null 2>&1 || true
  if git -C "$dst" rev-parse -q --verify "$commit^{commit}" >/dev/null 2>&1; then
    git -C "$dst" checkout "$commit" >/dev/null 2>&1 || true
  fi
}

stow_module() {
  local module="$1"

  if ! command -v stow >/dev/null 2>&1; then
    echo "GNU stow is required. Run scripts/base-utils.sh first." >&2
    exit 1
  fi

  (cd "$DOTFILES_DIR" && stow -v -t "$HOME" "$module")
}

unstow_module() {
  local module="$1"

  if ! command -v stow >/dev/null 2>&1; then
    return 0
  fi

  (cd "$DOTFILES_DIR" && stow -D -v -t "$HOME" "$module") || true
}
