# Credentials Setup (New Machine)

This bootstrap is portable, but authentication is machine/user-specific.

## 1) What bootstrap enforces

`./scripts/bootstrap.sh` runs `./scripts/git-credentials.sh` before `git.sh`:
- ensures `~/.ssh` exists with secure permissions
- ensures `ssh-agent` is running
- persists agent env to `~/.ssh/ssh-agent.env` for shell reuse
- requires both keypairs:
  - auth: `~/.ssh/id_ed25519` + `~/.ssh/id_ed25519.pub`
  - signing: `~/.ssh/github_signing_key` + `~/.ssh/github_signing_key.pub`

If keys are missing, it guides you with:
1. generate new keys and then add them to GitHub
2. import existing keys from a directory you provide

You can run this step manually first:

```bash
./scripts/git-credentials.sh
```

In this repo, `zsh/.zshenv` loads `~/.ssh/ssh-agent.env` (if present), so the
first interactive `zsh` after bootstrap can reuse the agent without extra
logic in `.zshrc`.

## 2) Manual key setup (if preferred)

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -a 64 -f ~/.ssh/id_ed25519 -C "<your_email>"
ssh-keygen -t ed25519 -a 64 -f ~/.ssh/github_signing_key -C "<your_email>"
```

Start agent and load keys:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add ~/.ssh/github_signing_key
```

## 3) Register keys in GitHub (browser)

1. Open: `https://github.com/settings/keys`
2. Add `~/.ssh/id_ed25519.pub` as an **Authentication** key.
3. Add `~/.ssh/github_signing_key.pub` as a **Signing** key.
4. Validate SSH access:

```bash
ssh -T git@github.com
```

Reference docs:
- `https://docs.github.com/en/authentication/connecting-to-github-with-ssh`

## 4) Git identity prompt on install

`./scripts/git.sh` asks for:
- `GitHub username` (`git user.name`)
- `GitHub e-mail` (`git user.email`)

It saves values in:
- `~/.config/git/local-user.conf`

For non-interactive runs:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@company.com"
```

For non-interactive key import:

```bash
export GIT_KEYS_SOURCE_DIR="/path/to/folder/with/id_ed25519+github_signing_key"
```

## 5) VS Code credentials/sync

Use Settings Sync as source of truth:
1. Open VS Code.
2. Sign in with Microsoft/GitHub account.
3. Enable Sync for `Settings`, `Extensions`, `Keybindings`, and `Snippets`.

The bootstrap does not force-install VS Code extensions.

## 6) Optional private registries

Only needed if your org uses private feeds.

- npm:
  - configure `~/.npmrc` / `NPM_TOKEN`
- NuGet:
  - `dotnet nuget add source ...`
- pip:
  - configure `~/.config/pip/pip.conf` or environment variables
