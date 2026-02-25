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

log() {
  printf '[bootstrap.sh] %s\n' "$*"
}

run_sanity_checks() {
  local missing=()
  local cmd
  for cmd in git gh zsh tmux python3 dotnet stow pwsh; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "[bootstrap.sh] Sanity checks failed; missing command(s): ${missing[*]}" >&2
    return 1
  fi

  if [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh" ]]; then
    echo "[bootstrap.sh] Sanity checks failed; zinit file not found." >&2
    return 1
  fi

  if command -v gh >/dev/null 2>&1 && ! gh extension list 2>/dev/null | awk '{print $2}' | grep -Fxq "dlvhdr/gh-dash"; then
    echo "[bootstrap.sh] Warning: gh extension 'dlvhdr/gh-dash' is not installed yet (authenticate gh then rerun scripts/gh.sh)." >&2
  fi

  log "Sanity checks passed"
}

ensure_projects_workspace() {
  mkdir -p "$HOME/projects"
  log "Ensured projects workspace at $HOME/projects"
}

handoff_to_zsh() {
  if ! command -v zsh >/dev/null 2>&1; then
    return 0
  fi

  if [[ -t 0 && -t 1 && "${TERM:-}" != "dumb" ]]; then
    log "Starting zsh to finalize shell setup"
    exec zsh
  fi
}

if [[ "$MODE" == "install" ]]; then
  "$SCRIPT_DIR/base-utils.sh"

  if [[ "${SKIP_GIT_CREDENTIALS_PREFLIGHT:-0}" != "1" ]]; then
    # Source credentials preflight so ssh-agent env persists in this process.
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/git-credentials.sh"
    ensure_git_credentials_prereqs
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

  run_sanity_checks
  ensure_projects_workspace
  handoff_to_zsh
else
  for ((i=${#ORDER[@]}-1; i>=0; i--)); do
    "$SCRIPT_DIR/${ORDER[$i]}" -U
  done
fi
