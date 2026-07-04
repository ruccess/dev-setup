# dev-setup

Fresh macOS development setup for terminal-first work.

This repo installs a focused CLI stack, links reusable shell config, and guides Git account/workspace setup. It is safe to run more than once.

## Quick Start

```zsh
cd path/to/dev-setup
./menu.sh
./install.sh --dry-run
./install.sh
```

Choose what to install. Interactive mode walks through each section one at a time. Non-interactive mode can select whole sections:

```zsh
./install.sh --list-brew-groups
./install.sh --brew-groups apps,terminal,shell,modern
./install.sh --all-brew
./install.sh --brew-groups none
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

Terminal workspaces:

- `zellij` for tabs, panes, sessions, and layouts
- `tmux` for classic terminal session management

Everyday CLI:

- `eza`, `bat`, `fd`, `ripgrep`, `sd`
- `jq`, `yq`
- `dust`, `duf`, `btop`
- `lnav`, `tailspin`
- `lazygit`, `lazydocker`, `k9s`, `yazi`
- `neovim`, `ast-grep`, `shellcheck`, `shfmt`, `actionlint`, `typos-cli`
- `git-lfs`, `pre-commit`, `difftastic`, `git-filter-repo`
- `duckdb`, `sqlite`, `miller`, `xsv`, `jless`, `fx`
- `gitleaks`, `trufflehog`, `age`, `sops`, `syft`, `grype`
- `claude-code`, `ollama`, `llm`, `aichat`, `mods`
- `gh`, `just`, `gum`, `hyperfine`, `xh`

Installer sections:

```text
apps        Ghostty, Raycast, JetBrains Mono Nerd Font
terminal    zellij, tmux
shell       starship, fzf, zoxide, atuin, mise, direnv
modern      eza, bat, fd, ripgrep, sd, jq, yq, dust, duf, git-delta
logs        lnav, tailspin, btop, lazygit, yazi
code        neovim, ast-grep, shellcheck, shfmt, actionlint, typos-cli
git         git-lfs, pre-commit, difftastic, git-filter-repo, jj
network     wget, doggo, gping, mtr, iperf3, nmap, bandwhich, trippy
data        duckdb, sqlite, miller, csvkit, xsv, jless, fx, visidata
containers  docker, docker-compose, colima, lazydocker, kubectl, helm, k9s
cloud       awscli, azure-cli, google-cloud-sdk, doctl, flyctl, opentofu
security    gitleaks, trufflehog, age, sops, cosign, syft, grype
media       ffmpeg, imagemagick, rclone, pandoc, poppler, sevenzip
runtimes    uv, bun, pnpm, deno
ai          Claude Code, ollama, llm, aichat, mods
workflow    gh, just, gum, hyperfine, xh
```

Inside interactive mode, each section supports:

```text
r  recommended
a  all
n  skip
c  custom per tool
```

## Useful Commands

After installing and opening a new terminal:

```zsh
ws              # jump to ~/workspace
p               # fuzzy-pick a project under ~/workspace
dh              # open the dev-setup learning guide
devhelp         # same as dh
devhelp-edit    # edit the learning guide
devrepo         # jump to this setup repo
dev-setup       # open the interactive setup menu
devmenu         # same as dev-setup
dm              # same as dev-setup
zjd             # open the Zellij dev workspace layout
lg              # lazygit
logs app.log    # open logs with lnav
tspin app.log   # highlight logs with tailspin
z workspace     # jump with zoxide
atuin search    # search shell history
git-account     # manage Welda/Ruccess Git accounts
nvprof          # manage Neovim starter profiles
nvl             # run nvim with the LazyVim profile
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
SKILL.md                         AI assistant operating guide for this repo
menu.sh                          Root wrapper for the interactive menu
install.sh                       Idempotent installer
docs/LEARN.md                    Learning guide and cheat sheet
config/zsh/dev-setup.zsh         Shell aliases and integrations
config/zellij/dev.kdl            Zellij dev workspace layout
config/starship/starship.toml    Prompt config
config/git/gitconfig             Git aliases and delta config
scripts/git-accounts.sh          Multi-account Git manager
scripts/neovim-profiles.sh       LazyVim/AstroNvim/NvChad profile helper
scripts/menu.sh                  Interactive setup/script menu
scripts/doctor.sh                Check installed tools
```

`install.sh` writes the selected package manifest to:

```text
~/.config/dev-setup/Brewfile.selected
```

## GitHub

Create a remote repo, then push:

```zsh
git remote add origin git@github.com:<you>/dev-setup.git
git push -u origin main
```
