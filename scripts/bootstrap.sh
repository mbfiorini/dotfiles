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

AUTH_KEY="${GIT_AUTH_KEY:-$HOME/.ssh/id_ed25519}"
SIGNING_KEY="${GIT_SIGNING_KEY:-$HOME/.ssh/github_signing_key}"

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

have_required_keys() {
  [[ -f "$AUTH_KEY" && -f "$AUTH_KEY.pub" && -f "$SIGNING_KEY" && -f "$SIGNING_KEY.pub" ]]
}

ensure_ssh_dir() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
}

ensure_ssh_agent() {
  local rc
  rc=0
  ssh-add -l >/dev/null 2>&1 || rc=$?
  if [[ $rc -eq 2 ]] || [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
    eval "$(ssh-agent -s)" >/dev/null
  fi
}

add_keys_to_agent() {
  ensure_ssh_agent
  ssh-add "$AUTH_KEY" >/dev/null 2>&1 || true
  ssh-add "$SIGNING_KEY" >/dev/null 2>&1 || true
}

generate_keys() {
  local email
  email="${GIT_USER_EMAIL:-}"
  [[ -n "$email" ]] || email="$(prompt_nonempty "GitHub e-mail for SSH key comment")"
  mkdir -p "$(dirname "$AUTH_KEY")" "$(dirname "$SIGNING_KEY")"

  if [[ ! -f "$AUTH_KEY" || ! -f "$AUTH_KEY.pub" ]]; then
    rm -f "$AUTH_KEY" "$AUTH_KEY.pub"
    ssh-keygen -t ed25519 -a 64 -f "$AUTH_KEY" -C "$email"
  fi

  if [[ ! -f "$SIGNING_KEY" || ! -f "$SIGNING_KEY.pub" ]]; then
    rm -f "$SIGNING_KEY" "$SIGNING_KEY.pub"
    ssh-keygen -t ed25519 -a 64 -f "$SIGNING_KEY" -C "$email"
  fi

  chmod 600 "$AUTH_KEY" "$SIGNING_KEY"
  chmod 644 "$AUTH_KEY.pub" "$SIGNING_KEY.pub"
}

import_existing_keys() {
  local src_dir
  src_dir="${GIT_KEYS_SOURCE_DIR:-}"
  if [[ -z "$src_dir" ]]; then
    src_dir="$(prompt_nonempty "Directory containing id_ed25519 and github_signing_key")"
  fi
  src_dir="$(expand_home_path "$src_dir")"

  if [[ ! -d "$src_dir" ]]; then
    echo "Directory not found: $src_dir" >&2
    return 1
  fi

  local required=(id_ed25519 id_ed25519.pub github_signing_key github_signing_key.pub)
  local filename
  for filename in "${required[@]}"; do
    if [[ ! -f "$src_dir/$filename" ]]; then
      echo "Missing required file: $src_dir/$filename" >&2
      return 1
    fi
  done

  mkdir -p "$(dirname "$AUTH_KEY")" "$(dirname "$SIGNING_KEY")"
  install -m 600 "$src_dir/id_ed25519" "$AUTH_KEY"
  install -m 644 "$src_dir/id_ed25519.pub" "$AUTH_KEY.pub"
  install -m 600 "$src_dir/github_signing_key" "$SIGNING_KEY"
  install -m 644 "$src_dir/github_signing_key.pub" "$SIGNING_KEY.pub"

  if [[ -f "$src_dir/allowed_signers" ]]; then
    install -m 600 "$src_dir/allowed_signers" "$HOME/.ssh/allowed_signers"
  fi
}

guide_github_key_registration() {
  echo
  echo "Git SSH keys are ready."
  echo "Register both keys in GitHub using the browser:"
  echo "  1) Open: https://github.com/settings/keys"
  echo "  2) Add auth key file: $AUTH_KEY.pub (Authentication key)"
  echo "  3) Add signing key file: $SIGNING_KEY.pub (Signing key)"
  echo "Docs: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
  echo "  ssh -T git@github.com"
  echo
}

ensure_git_credentials_prereqs() {
  ensure_ssh_dir
  AUTH_KEY="$(expand_home_path "$AUTH_KEY")"
  SIGNING_KEY="$(expand_home_path "$SIGNING_KEY")"
  mkdir -p "$(dirname "$AUTH_KEY")" "$(dirname "$SIGNING_KEY")"

  if have_required_keys; then
    add_keys_to_agent
    return 0
  fi

  if [[ ! -t 0 ]]; then
    if [[ -n "${GIT_KEYS_SOURCE_DIR:-}" ]]; then
      import_existing_keys
      add_keys_to_agent
      guide_github_key_registration
      return 0
    fi
    echo "Missing git SSH keys. Set GIT_KEYS_SOURCE_DIR or run interactively." >&2
    echo "See docs/credentials-setup.md" >&2
    exit 1
  fi

  echo
  echo "Git credential preflight: missing SSH auth/signing keys."
  while ! have_required_keys; do
    echo "Choose one option:"
    echo "  1) Generate new keys and then add them to GitHub"
    echo "  2) Use existing keys from a directory"
    echo "  3) Abort"
    read -r -p "Selection [1/2/3]: " choice
    case "$choice" in
      1)
        generate_keys
        ;;
      2)
        if ! import_existing_keys; then
          echo "Could not import keys; try again." >&2
        fi
        ;;
      3)
        echo "Aborted by user." >&2
        exit 1
        ;;
      *)
        echo "Invalid option. Choose 1, 2 or 3." >&2
        ;;
    esac
  done

  add_keys_to_agent
  guide_github_key_registration
}

if [[ "$MODE" == "install" ]]; then
  "$SCRIPT_DIR/base-utils.sh"
  ensure_git_credentials_prereqs
  for s in "${ORDER[@]:1}"; do
    "$SCRIPT_DIR/$s"
  done
else
  for ((i=${#ORDER[@]}-1; i>=0; i--)); do
    "$SCRIPT_DIR/${ORDER[$i]}" -U
  done
fi
