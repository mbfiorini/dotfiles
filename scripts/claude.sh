#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

# Initial version for the native installer; Claude Code auto-updates afterwards.
CLAUDE_VERSION="${CLAUDE_VERSION:-2.1.327}"
CLAUDE_BIN="$HOME/.local/bin/claude"
CLAUDE_DATA="$HOME/.local/share/claude"

# Files managed by the `claude` stow module. Pre-existing regular files are
# moved aside so stow can link them (Claude creates settings.json on first run).
MANAGED_FILES=(
  "$HOME/.claude/settings.json"
  "$HOME/.claude/CLAUDE.md"
)

backup_conflicts() {
  local f ts
  ts="$(date +%Y%m%d%H%M%S)"
  for f in "${MANAGED_FILES[@]}"; do
    if [[ -e "$f" && ! -L "$f" ]]; then
      mv "$f" "$f.stow-bak-$ts"
      log "Moved existing $f to $f.stow-bak-$ts"
    fi
  done
}

if [[ "$MODE" == "install" ]]; then
  # bubblewrap + socat are required by Claude Code's optional Linux sandbox (/sandbox).
  apt_install ca-certificates curl bubblewrap socat

  if [[ ! -x "$CLAUDE_BIN" ]]; then
    curl -fsSL https://claude.ai/install.sh | bash -s "$CLAUDE_VERSION"
  else
    log "Claude Code already installed ($("$CLAUDE_BIN" --version 2>/dev/null || echo unknown))"
  fi

  mkdir -p "$HOME/.claude"
  backup_conflicts
  stow_module claude

  log "Installed Claude Code and applied module (run 'claude' once to log in)"
else
  unstow_module claude
  rm -f "$CLAUDE_BIN"
  rm -rf "$CLAUDE_DATA"
  log "Removed Claude Code binary; kept ~/.claude (auth, history, projects) and ~/.claude.json"
fi
