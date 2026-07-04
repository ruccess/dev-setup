# dev-setup

Fresh macOS development setup for terminal-first work.

This repo installs a focused CLI stack, links reusable shell config, and adds a small managed block to `~/.zshrc`. It is safe to run more than once.

## Quick Start

```zsh
cd ~/workspace/dev-setup
./install.sh --dry-run
./install.sh
```

## What It Installs

Apps:

- Ghostty
- Raycast
- JetBrains Mono Nerd Font

Shell:

- `starship` for the prompt
- `fzf` for fuzzy selection
- `zoxide` for smarter directory jumps
- `atuin` for searchable shell history
- `mise` for runtime version management
- `direnv` for per-project environment loading

Everyday CLI:

- `eza`, `bat`, `fd`, `ripgrep`, `sd`
- `jq`, `yq`
- `dust`, `duf`, `btop`
- `lnav`, `tailspin`
- `lazygit`, `lazydocker`, `k9s`, `yazi`, `tmux`
- `just`, `gum`, `hyperfine`, `xh`

## Useful Commands

After installing and opening a new terminal:

```zsh
ws              # jump to ~/workspace
p               # fuzzy-pick a project under ~/workspace
lg              # lazygit
logs app.log    # open logs with lnav
tspin app.log   # highlight logs with tailspin
z workspace     # jump with zoxide
atuin search    # search shell history
```

## Files

```text
Brewfile                         Homebrew bundle
install.sh                       Idempotent installer
config/zsh/dev-setup.zsh         Shell aliases and integrations
config/starship/starship.toml    Prompt config
config/git/gitconfig             Git aliases and delta config
scripts/doctor.sh                Check installed tools
```

## GitHub

Create a remote repo, then push:

```zsh
git remote add origin git@github.com:<you>/dev-setup.git
git push -u origin main
```

