#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/mbfiorini/dotfiles.git}"
DOTFILES_REF="${DOTFILES_REF:-main}"

MODE="install"
if [[ "${1:-}" == "-U" ]]; then
  MODE="uninstall"
  shift
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $(basename "$0") [-U]" >&2
  exit 1
fi

need_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    SUDO=""
  else
    SUDO="sudo"
  fi
}

ensure_git() {
  if command -v git >/dev/null 2>&1; then
    return 0
  fi

  need_sudo
  ${SUDO} apt-get update
  DEBIAN_FRONTEND=noninteractive ${SUDO} apt-get install -y git ca-certificates
}

clone_repo_if_missing() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    return 0
  fi

  git clone --branch "$DOTFILES_REF" --single-branch "$DOTFILES_REPO" "$DOTFILES_DIR"
}

if [[ "$MODE" == "install" ]]; then
  ensure_git
  clone_repo_if_missing

  "$DOTFILES_DIR/scripts/git-credentials.sh"
  SKIP_GIT_CREDENTIALS_PREFLIGHT=1 "$DOTFILES_DIR/scripts/bootstrap.sh"
else
  if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    echo "Cannot uninstall: $DOTFILES_DIR is not a git clone." >&2
    exit 1
  fi
  "$DOTFILES_DIR/scripts/bootstrap.sh" -U
fi
