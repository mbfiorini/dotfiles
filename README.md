# dotfiles

Portable Ubuntu bootstrap + user configuration repo.

Goal:
- Recreate this machine setup on any Ubuntu >= current version.
- Keep app user-config under app modules in `~/dotfiles/<app>/`.
- Install/uninstall each component idempotently via scripts with `-U` flag.

## Repo structure

- `git/`, `gh/`, `zsh/`, `tmux/`, `lazygit/`, `vscode/`: stow modules with user config.
- `scripts/manifests/gh-extensions.txt`: declarative `gh` extension list used by `scripts/gh.sh`.
- `scripts/manifests/vscode-extensions.txt`: merged backup list of VS Code extensions (reference only).
- `scripts/git-credentials.sh`: standalone Git SSH auth/signing preflight.
- `scripts/<software>.sh`: install script for each software/tooling area.
- `scripts/bootstrap.sh`: executes all scripts in the correct order.
- `install.sh`: first-run entrypoint (clone if missing, credentials preflight, then bootstrap).
- `docs/credentials-setup.md`: SSH/auth/signing/bootstrap credentials runbook for new machines.
- `docs/non-default-inventory.md`: captured inventory from this source machine.
- `docs/apt-manual-full.txt`: full `apt-mark showmanual` snapshot from this source machine.

## Prerequisites

1. Ubuntu (same major version or newer recommended)
2. sudo access
3. internet access

## Quickstart (fresh machine)

If this repository is public, you can bootstrap from HTTPS without preconfigured GitHub SSH auth:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mbfiorini/dotfiles/main/install.sh)"
```

This command will:
1. install `git` if missing
2. clone `~/dotfiles` via HTTPS if missing
3. run `scripts/git-credentials.sh` (interactive key setup/import)
4. run `scripts/bootstrap.sh`
5. run sanity checks, ensure `~/projects`, then hand off to `zsh`

`install.sh` enables continue-on-error mode in bootstrap so one failing component does not stop later installers.

## Clone

```bash
git clone <YOUR_GITHUB_REPO_URL> ~/dotfiles
cd ~/dotfiles
```

For credentials (SSH keys, `gh` auth, optional signing), follow:

```bash
less docs/credentials-setup.md
```

`./scripts/bootstrap.sh` also runs `./scripts/git-credentials.sh` (unless `SKIP_GIT_CREDENTIALS_PREFLIGHT=1`).

Note about clone protocol:
- `https://github.com/...` clone of a public repo does not require GitHub auth.
- `git@github.com:...` clone requires working SSH auth key on the machine.

## Execution order (install)

Run scripts in this exact order:

1. `./scripts/base-utils.sh`
2. `./scripts/git.sh`
3. `./scripts/fonts.sh`
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
- `bootstrap.sh` enforces Git credential preflight first (SSH dir/agent + required keypairs) before `git.sh`.
- At successful end, `bootstrap.sh` runs sanity checks, ensures `~/projects`, and starts `zsh` when interactive.
- GitHub key registration in preflight guidance is browser-based (`https://github.com/settings/keys`), so it works before `gh` is installed/configured.
- `git.sh` requires both keypairs (`~/.ssh/id_ed25519*` and `~/.ssh/github_signing_key*` by default), asks for `GitHub username`/`GitHub e-mail`, then stores identity in `~/.config/git/local-user.conf`.
- `gh.sh` installs extensions listed in `scripts/manifests/gh-extensions.txt` (currently `dlvhdr/gh-dash`) and removes them on `-U`.
- `gh.sh` skips extension installation when `gh` is not authenticated yet, so bootstrap can continue; rerun `./scripts/gh.sh` after `gh auth login`.
- `zsh.sh` installs `zinit` and `zsh/.config/zsh/.zshrc` declares plugins/themes through the manager (no plugin git clones in installer scripts).
- `dotnet.sh` installs SDK 8.0 + global tools (`dotnet-ef`, `dotnet-format`) pinned to the versions detected.
- `node.sh` installs nvm pinned to the detected commit and Node `22.22.0`.
- `vscode` module currently tracks `~/.config/Code/User/mcp.json` only.
- `vscode.sh` is intentionally minimal and does not install extensions; use VS Code Settings Sync (Microsoft/GitHub sign-in) as the source of truth for editor settings and extensions.

## Projects workspace

`gh-dash` in this repo is configured for local clones under `~/projects/<repo-name>`.
Use `gh repo clone` to create local repos; `gh-dash` then maps PRs/issues to
those local paths via `repoPaths`.

Examples:

```bash
mkdir -p ~/projects
gh repo clone geniality-br/geniality-datasul ~/projects/geniality-datasul
gh repo clone mbfiorini/dotfiles ~/projects/dotfiles
```

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
