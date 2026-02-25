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

CONTINUE_ON_ERROR="${BOOTSTRAP_CONTINUE_ON_ERROR:-0}"

ORDER=(
  base-utils.sh
  git.sh
  fonts.sh
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
  "$SCRIPT_DIR/base-utils.sh"

  if [[ "${SKIP_GIT_CREDENTIALS_PREFLIGHT:-0}" != "1" ]]; then
    "$SCRIPT_DIR/git-credentials.sh"
  fi

  failed=()
  for s in "${ORDER[@]:1}"; do
    if ! "$SCRIPT_DIR/$s"; then
      if [[ "$CONTINUE_ON_ERROR" == "1" ]]; then
        echo "[bootstrap.sh] Warning: '$s' failed; continuing." >&2
        failed+=("$s")
      else
        exit 1
      fi
    fi
  done

  if [[ ${#failed[@]} -gt 0 ]]; then
    echo "[bootstrap.sh] Completed with failures: ${failed[*]}" >&2
    exit 1
  fi
else
  for ((i=${#ORDER[@]}-1; i>=0; i--)); do
    "$SCRIPT_DIR/${ORDER[$i]}" -U
  done
fi
