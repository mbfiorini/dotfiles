# XDG base directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Place zsh runtime config in ~/.config/zsh
export ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# Load persisted ssh-agent environment written by scripts/git-credentials.sh.
SSH_AGENT_ENV_FILE="${GIT_SSH_AGENT_ENV_FILE:-$HOME/.ssh/ssh-agent.env}"
if [[ -f "$SSH_AGENT_ENV_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$SSH_AGENT_ENV_FILE" >/dev/null 2>&1 || true
fi
