#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

LOCAL_GIT_DIR="$HOME/.config/git"
LOCAL_USER_FILE="$LOCAL_GIT_DIR/local-user.conf"
LOCAL_SIGNING_FILE="$LOCAL_GIT_DIR/local-signing.conf"
AUTH_KEY="${GIT_AUTH_KEY:-$HOME/.ssh/id_ed25519}"
AUTH_KEY_PUB="${GIT_AUTH_KEY_PUB:-$AUTH_KEY.pub}"
SIGNING_KEY="${GIT_SIGNING_KEY:-$HOME/.ssh/github_signing_key}"
SIGNING_KEY_PUB="${GIT_SIGNING_KEY_PUB:-$SIGNING_KEY.pub}"
ALLOWED_SIGNERS_FILE="${GIT_ALLOWED_SIGNERS_FILE:-$HOME/.ssh/allowed_signers}"

expand_home_path() {
  local value="$1"
  if [[ "$value" == "~"* ]]; then
    printf '%s' "${value/#\~/$HOME}"
  else
    printf '%s' "$value"
  fi
}

prompt_nonempty() {
  local label="$1"
  local value=""

  while [[ -z "$value" ]]; do
    read -r -p "$label: " value
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
  done

  printf '%s' "$value"
}

ensure_git_identity() {
  mkdir -p "$LOCAL_GIT_DIR"

  local name email
  name="$(git config -f "$LOCAL_USER_FILE" --get user.name 2>/dev/null || true)"
  email="$(git config -f "$LOCAL_USER_FILE" --get user.email 2>/dev/null || true)"

  if [[ -n "$name" && -n "$email" ]]; then
    log "Git identity already configured in $LOCAL_USER_FILE"
    return 0
  fi

  name="${GIT_USER_NAME:-$name}"
  email="${GIT_USER_EMAIL:-$email}"

  if [[ -z "$name" || -z "$email" ]]; then
    if [[ -t 0 ]]; then
      echo
      echo "Git identity setup (saved to $LOCAL_USER_FILE)"
      [[ -n "$name" ]] || name="$(prompt_nonempty "GitHub username (git user.name)")"
      [[ -n "$email" ]] || email="$(prompt_nonempty "GitHub e-mail (git user.email)")"
    else
      echo "Missing git identity. Set GIT_USER_NAME and GIT_USER_EMAIL for non-interactive runs." >&2
      exit 1
    fi
  fi

  rm -f "$LOCAL_USER_FILE"
  git config -f "$LOCAL_USER_FILE" user.name "$name"
  git config -f "$LOCAL_USER_FILE" user.email "$email"
  log "Saved git identity to $LOCAL_USER_FILE"
}

ensure_required_git_keys() {
  AUTH_KEY="$(expand_home_path "$AUTH_KEY")"
  AUTH_KEY_PUB="$(expand_home_path "$AUTH_KEY_PUB")"
  SIGNING_KEY="$(expand_home_path "$SIGNING_KEY")"
  SIGNING_KEY_PUB="$(expand_home_path "$SIGNING_KEY_PUB")"
  ALLOWED_SIGNERS_FILE="$(expand_home_path "$ALLOWED_SIGNERS_FILE")"

  local missing=0
  local f
  for f in "$AUTH_KEY" "$AUTH_KEY_PUB" "$SIGNING_KEY" "$SIGNING_KEY_PUB"; do
    if [[ ! -f "$f" ]]; then
      echo "Missing required key file: $f" >&2
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    echo "git.sh requires both SSH auth and signing keypairs." >&2
    echo "Run ./scripts/bootstrap.sh to complete credentials preflight first." >&2
    echo "See docs/credentials-setup.md for details." >&2
    exit 1
  fi
}

ensure_git_signing() {
  mkdir -p "$LOCAL_GIT_DIR"

  local email pub_content
  email="$(git config -f "$LOCAL_USER_FILE" --get user.email 2>/dev/null || true)"
  pub_content="$(tr -d '\r\n' < "$SIGNING_KEY_PUB")"

  rm -f "$LOCAL_SIGNING_FILE"
  if [[ ! -f "$ALLOWED_SIGNERS_FILE" ]]; then
    mkdir -p "$(dirname "$ALLOWED_SIGNERS_FILE")"
    printf "%s %s\n" "${email:-$(whoami)}" "$pub_content" > "$ALLOWED_SIGNERS_FILE"
    chmod 600 "$ALLOWED_SIGNERS_FILE"
    log "Created $ALLOWED_SIGNERS_FILE"
  fi

  git config -f "$LOCAL_SIGNING_FILE" gpg.format ssh
  git config -f "$LOCAL_SIGNING_FILE" gpg.ssh.program /usr/bin/ssh-keygen
  git config -f "$LOCAL_SIGNING_FILE" gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS_FILE"
  git config -f "$LOCAL_SIGNING_FILE" user.signingkey "$SIGNING_KEY_PUB"
  git config -f "$LOCAL_SIGNING_FILE" commit.gpgsign true
  log "Enabled git signing via $LOCAL_SIGNING_FILE"
}

if [[ "$MODE" == "install" ]]; then
  apt_install git
  ensure_required_git_keys
  stow_module git
  ensure_git_identity
  ensure_git_signing
  log "Installed git and applied dotfiles module"
else
  rm -f "$LOCAL_USER_FILE" "$LOCAL_SIGNING_FILE"
  unstow_module git
  apt_remove git
  log "Removed git local identity/signing files, and unstowed module"
fi
