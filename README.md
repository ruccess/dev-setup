# dev-setup

Fresh macOS development setup for terminal-first work.

This repo installs a focused CLI stack, links reusable shell config, and guides Git account/workspace setup. It is safe to run more than once.

## Quick Start

```zsh
cd path/to/dev-setup
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
- `gh`, `just`, `gum`, `hyperfine`, `xh`

## Useful Commands

After installing and opening a new terminal:

```zsh
ws              # jump to ~/workspace
p               # fuzzy-pick a project under ~/workspace
dh              # open the dev-setup learning guide
devhelp         # same as dh
devhelp-edit    # edit the learning guide
devrepo         # jump to this setup repo
lg              # lazygit
logs app.log    # open logs with lnav
tspin app.log   # highlight logs with tailspin
z workspace     # jump with zoxide
atuin search    # search shell history
git-account     # manage Welda/Ruccess Git accounts
```

## Git Accounts

This setup supports multiple Git identities. During setup, you choose account IDs and workspace folders. For example, this machine uses:

```text
ruccess -> ~/workspace/ruccess
welda   -> ~/workspace/welda
```

Run:

```zsh
git-account init
```

It creates local account configs under:

```text
~/.config/dev-setup/git/accounts/<account>.gitconfig
```

Repos under the folder you choose for an account use that account automatically.

```text
~/workspace/<account>/
```

For an existing repo outside those folders:

```zsh
git-account set-repo welda ~/workspace/welda/api
git-account current ~/workspace/welda/api
```

For GitHub SSH keys:

```zsh
git-account key welda
git-account key ruccess
```

Add each public key to the matching GitHub account, then use SSH host aliases:

```text
git@github.com-welda:welda/repo.git
git@github.com-ruccess:ruccess/repo.git
```

To rewrite an existing GitHub remote:

```zsh
git-account remote ruccess origin ~/workspace/ruccess/dev-setup
```

## Files

```text
Brewfile                         Homebrew bundle
install.sh                       Idempotent installer
docs/LEARN.md                    Learning guide and cheat sheet
config/zsh/dev-setup.zsh         Shell aliases and integrations
config/starship/starship.toml    Prompt config
config/git/gitconfig             Git aliases and delta config
scripts/git-accounts.sh          Multi-account Git manager
scripts/doctor.sh                Check installed tools
```

## GitHub

Create a remote repo, then push:

```zsh
git remote add origin git@github.com:<you>/dev-setup.git
git push -u origin main
```
