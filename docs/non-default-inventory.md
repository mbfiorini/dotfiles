# Detected Non-Default Inventory (this machine)

Generated on: 2026-02-23
Host: Ubuntu on WSL2 (`systemd=true`)

## Versions detected
- zsh `5.9`
- tmux `3.4`
- git `2.43.0`
- gh `2.86.0`
- dotnet SDK `8.0.124`
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
- build-essential
- curl
- dotnet-sdk-8.0
- eza
- fd-find
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
- tmux
- unzip
- xclip
- zip
- zoxide
- zsh

## Zsh ecosystem detected
- Oh My Zsh: `ohmyzsh/ohmyzsh` @ `88659ed`
- zsh plugins loaded: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- zsh-autosuggestions: `zsh-users/zsh-autosuggestions` @ `85919cd`
- zsh-syntax-highlighting: `zsh-users/zsh-syntax-highlighting` @ `5eb677b`
- powerlevel10k: `romkatv/powerlevel10k` @ `efc9ddd`
- catppuccin theme pack: `catppuccin/zsh-syntax-highlighting` @ `7926c3d`

## tmux plugins detected
- tpm @ `99469c4`
- tmux-sensible @ `25cb91f`
- vim-tmux-navigator @ `e41c431`
- catppuccin-tmux @ `b4e0715`
- tmux-yank @ `acfd36e`

## gh extensions detected
- gh-dash: `dlvhdr/gh-dash` `v4.22.0`

## Global tools detected
- dotnet tools:
  - dotnet-ef `10.0.2`
  - dotnet-format `5.1.250801`
- npm global packages:
  - @openai/codex `0.104.0`
  - corepack `0.34.0`
- pipx packages:
  - tldr `3.4.4`

## Bundling status in `~/dotfiles/scripts`
- bundled: zsh plugins/themes, tmux plugins, gh extensions, dotnet global tools, npm globals, pipx packages
- zsh install strategy in this repo: manager-first via `zinit` declarations inside `zsh/.config/zsh/.zshrc`
- VS Code strategy: use VS Code Settings Sync account data for extensions/preferences; keep only a backup extension list in `scripts/manifests/vscode-extensions.txt`
