# Detected Non-Default Inventory (this machine)

Generated on: 2026-04-28
Host: Ubuntu 24.04.3 LTS on WSL2 (`systemd=true`)

## Versions detected
- zsh `5.9`
- tmux `3.4`
- git `2.43.0`
- gh `2.86.0`
- dotnet SDKs `8.0.126`, `10.0.107`
- python `3.12.3`
- node `v22.22.0` (via nvm)
- npm `10.9.4`
- lazygit `0.59.0`
- zoxide `0.9.3`
- fzf `0.44.1`
- bat `0.24.0`
- fd/fdfind `9.0.0`

## Manual apt packages detected (curated)
- apt-transport-https
- bat
- bubblewrap
- build-essential
- curl
- dotnet-sdk-8.0
- dotnet-sdk-10.0
- eza
- fd-find
- fonts-freefont-ttf
- fonts-ipafont-gothic
- fonts-liberation
- fonts-noto-color-emoji
- fonts-tlwg-loma-otf
- fonts-unifont
- fonts-wqy-zenhei
- fzf
- gh
- git
- jq
- nodejs
- npm
- pipx
- powershell
- python3-pip
- python3-venv
- ripgrep
- software-properties-common
- stow
- tmux
- unzip
- wget
- xclip
- xfonts-cyrillic
- xfonts-scalable
- zip
- zoxide
- zsh

## Zsh ecosystem detected
- Zinit: `zdharma-continuum/zinit` @ `87a8e6b`
- zsh snippets/plugins declared: `OMZP::git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`
- zsh-autosuggestions: `zsh-users/zsh-autosuggestions` @ `85919cd`
- zsh-syntax-highlighting: `zsh-users/zsh-syntax-highlighting` @ `1d85c69`
- zsh-completions: `zsh-users/zsh-completions` @ `684021f`
- powerlevel10k: `romkatv/powerlevel10k` @ `8ed1f58`
- catppuccin theme pack: `catppuccin/zsh-syntax-highlighting` @ `7926c3d`

## tmux plugins detected
- tpm @ `99469c4`
- additional TPM-managed plugins are declared in `tmux/.config/tmux/tmux.conf`, but only `tpm` is currently cloned under `~/.tmux/plugins`

## gh extensions detected
- gh-dash: `dlvhdr/gh-dash` `v4.22.0`
- gh-enhance: `dlvhdr/gh-enhance` `v0.5.1`

## Global tools detected
- dotnet tools:
  - dotnet-ef `10.0.2`
  - dotnet-format `5.1.250801`
- npm global packages:
  - @openai/codex `0.124.0`
  - corepack `0.34.0`
- pipx packages:
  - tldr `3.4.4`

## Bundling status in `~/dotfiles/scripts`
- bundled: zsh plugin/theme declarations, tmux TPM config, gh extension manifest, dotnet global tools, npm globals, pipx packages
- extra machine-local drift detected: gh extension `gh-enhance`; `@openai/codex` is newer than the version pinned in `scripts/node.sh`
- zsh install strategy in this repo: manager-first via `zinit` declarations inside `zsh/.config/zsh/.zshrc`
- tmux install strategy in this repo: TPM bootstrap via `tmux/.config/tmux/tmux.conf`
- VS Code strategy: use VS Code Settings Sync account data for extensions/preferences; keep only a backup extension list in `scripts/manifests/vscode-extensions.txt`
