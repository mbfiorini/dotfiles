#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common.sh"

parse_mode "$@"

setup_microsoft_repo() {
  local version_id
  version_id="$(. /etc/os-release && echo "$VERSION_ID")"

  if dpkg -s packages-microsoft-prod >/dev/null 2>&1; then
    return 0
  fi

  apt_install ca-certificates curl gnupg lsb-release

  local tmp_dir
  local deb
  tmp_dir="$(mktemp -d)"
  deb="$tmp_dir/packages-microsoft-prod.deb"

  if ! curl -fsSL "https://packages.microsoft.com/config/ubuntu/${version_id}/packages-microsoft-prod.deb" -o "$deb"; then
    curl -fsSL "https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb" -o "$deb"
  fi

  need_sudo
  ${SUDO} dpkg -i "$deb"
  rm -rf "$tmp_dir"
}

refresh_apt_lists_for_powershell_repo() {
  # base-utils may have already run apt update; force refresh so the new
  # Microsoft repository is visible in this same bootstrap run.
  rm -f /tmp/dotfiles-apt-updated.flag
  apt_update
}

if [[ "$MODE" == "install" ]]; then
  setup_microsoft_repo
  refresh_apt_lists_for_powershell_repo
  apt_install powershell
  log "Installed powershell"
else
  apt_remove powershell
  log "Removed powershell"
fi
