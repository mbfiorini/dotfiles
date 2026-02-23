# dotfiles

Portable Ubuntu bootstrap + user configuration repo.

Goal:
- Recreate this machine setup on any Ubuntu >= current version.
- Keep app user-config under app modules in `~/dotfiles/<app>/`.
- Install/uninstall each component idempotently via scripts with `-U` flag.

## Repo structure

- `git/`, `gh/`, `zsh/`, `tmux/`, `lazygit/`, `vscode/`: stow modules with user config.
- `scripts/<software>.sh`: install script for each software/tooling area.
- `scripts/bootstrap.sh`: executes all scripts in the correct order.
- `docs/non-default-inventory.md`: captured inventory from this source machine.
- `docs/apt-manual-full.txt`: full `apt-mark showmanual` snapshot from this source machine.

## Prerequisites

1. Ubuntu (same major version or newer recommended)
2. sudo access
3. internet access
4. git (if missing: `sudo apt-get update && sudo apt-get install -y git`)

## Clone

```bash
git clone <YOUR_GITHUB_REPO_URL> ~/dotfiles
cd ~/dotfiles
```

## Execution order (install)

Run scripts in this exact order:

1. `./scripts/base-utils.sh`
2. `./scripts/fonts.sh`
3. `./scripts/git.sh`
4. `./scripts/gh.sh`
5. `./scripts/zsh.sh`
6. `./scripts/tmux.sh`
7. `./scripts/node.sh`
8. `./scripts/python.sh`
9. `./scripts/dotnet.sh`
10. `./scripts/lazygit.sh`
11. `./scripts/powershell.sh`
12. `./scripts/vscode.sh`

Or run all in order:

```bash
./scripts/bootstrap.sh
```

## Uninstall flow

Each installer supports `-U` and is idempotent.

Examples:

```bash
./scripts/zsh.sh -U
./scripts/node.sh -U
./scripts/dotnet.sh -U
```

Remove everything in reverse order:

```bash
./scripts/bootstrap.sh -U
```

## Stow-managed modules

The following scripts stow/unstow user config automatically:
- `git.sh` -> module `git`
- `gh.sh` -> module `gh`
- `zsh.sh` -> module `zsh`
- `tmux.sh` -> module `tmux`
- `lazygit.sh` -> module `lazygit`
- `vscode.sh` -> module `vscode`

## Notes

- Sensitive files are intentionally not tracked (`.ssh`, `.gnupg`, auth tokens).
- `gh` authentication is not automated. Run `gh auth login` manually.
- `zsh.sh` installs Oh My Zsh + plugins/themes pinned to the commits captured from this machine.
- `dotnet.sh` installs SDK 8.0 + global tools (`dotnet-ef`, `dotnet-format`) pinned to the versions detected.
- `node.sh` installs nvm pinned to the detected commit and Node `22.22.0`.
- `vscode` module currently tracks `~/.config/Code/User/mcp.json` only.

## GitHub workflow

After first local setup:

```bash
cd ~/dotfiles
git init
git add .
git commit -m "Bootstrap portable Ubuntu dotfiles and installers"
git branch -M main
git remote add origin <YOUR_GITHUB_REPO_URL>
git push -u origin main
```

## Updates on this machine

When you change local config, sync back:

```bash
cd ~/dotfiles
# edit module files as needed
git add .
git commit -m "Update configs"
git push
```
