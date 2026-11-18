# User-level instructions (all projects)

- Be pragmatic: short, practical technical answers; expand only when asked.
- Environment: WSL2 Ubuntu. Windows tooling is reachable through interop (`powershell.exe`, `*.exe`).
- Projects live under `~/projects/<repo>`; dotfiles under `~/dotfiles` (GNU stow modules).
- Repositories use the tool-neutral `AGENTS.md` convention (shared with other agents); skills live in `.agents/skills/`.
  Only the root/ancestor `AGENTS.md` loads automatically: before editing files in a subdirectory,
  read the nearest `AGENTS.md` above them.
