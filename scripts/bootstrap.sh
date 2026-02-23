#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

MODE="install"
if [[ "${1:-}" == "-U" ]]; then
  MODE="uninstall"
  shift
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $(basename "$0") [-U]" >&2
  exit 1
fi

ORDER=(
  base-utils.sh
  fonts.sh
  git.sh
  gh.sh
  zsh.sh
  tmux.sh
  node.sh
  python.sh
  dotnet.sh
  lazygit.sh
  powershell.sh
  vscode.sh
)

if [[ "$MODE" == "install" ]]; then
  for s in "${ORDER[@]}"; do
    "$SCRIPT_DIR/$s"
  done
else
  for ((i=${#ORDER[@]}-1; i>=0; i--)); do
    "$SCRIPT_DIR/${ORDER[$i]}" -U
  done
fi
