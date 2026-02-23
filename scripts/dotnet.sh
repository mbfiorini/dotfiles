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

if [[ "$MODE" == "install" ]]; then
  setup_microsoft_repo
  apt_install dotnet-sdk-8.0

  dotnet tool update --global dotnet-ef --version 10.0.2
  dotnet tool update --global dotnet-format --version 5.1.250801

  log "Installed dotnet SDK and global dotnet tools"
else
  dotnet tool uninstall --global dotnet-ef >/dev/null 2>&1 || true
  dotnet tool uninstall --global dotnet-format >/dev/null 2>&1 || true

  apt_remove dotnet-sdk-8.0
  log "Removed dotnet SDK and global dotnet tools"
fi
