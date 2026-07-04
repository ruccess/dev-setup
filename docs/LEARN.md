# dev-setup Learning Guide

This is the everyday guide for the setup. Open it any time with:

```zsh
dh
devhelp
```

Edit it with:

```zsh
devhelp-edit
```

Jump to the setup repo with:

```zsh
devrepo
```

## First Run

Install everything:

```zsh
cd ~/workspace/dev-setup
./install.sh
source ~/.zshrc
./scripts/doctor.sh
```

Dry run first if you want to preview changes:

```zsh
./install.sh --dry-run
```

## Mental Model

This setup has four layers:

1. `Brewfile` installs apps and CLI tools.
2. `install.sh` links config into `~/.config` and adds one managed block to `~/.zshrc`.
3. `config/zsh/dev-setup.zsh` defines aliases, helper functions, and shell integrations.
4. `scripts/doctor.sh` checks whether the setup is healthy.

Most daily usage happens through small commands:

```zsh
ws
p
dh
lg
logs
git-account
```

## Daily Navigation

Jump to workspace:

```zsh
ws
```

Fuzzy-pick a project under `~/workspace`:

```zsh
p
```

Pick a project under another directory:

```zsh
p ~/code
```

Create a directory and enter it:

```zsh
mkcd ~/workspace/personal/new-project
```

Use zoxide for smart jumps:

```zsh
z workspace
z dev-setup
zi
```

## Search And Files

Find text:

```zsh
rg "someFunction"
rg "TODO" ~/workspace
```

Find files:

```zsh
fd package.json
fd README ~/workspace
```

List files:

```zsh
ll
la
lt
```

Preview a file:

```zsh
bat README.md
catp README.md
```

## Logs

Open logs with lnav:

```zsh
logs app.log
lnav app.log
lnav logs/*.log
```

Highlight a stream with tailspin:

```zsh
tail -f app.log | tspin
tspin app.log
```

Useful lnav keys:

```text
/        search
f        filter prompt
e        jump between errors
w        jump between warnings
q        quit
```

## Git

Quick aliases:

```zsh
g st
g lg
g last
lg
```

`g` is `git`. `lg` is `lazygit`.

Open the current repo in lazygit:

```zsh
lg
```

Use delta automatically for better diffs:

```zsh
git diff
git show
```

## Work And Personal Git Accounts

Initialize accounts:

```zsh
git-account init
```

Check the active identity:

```zsh
git-account current
git-account current ~/workspace/wd-cron
```

Pin one repo to work:

```zsh
git-account set-repo work ~/workspace/wd-cron
```

Pin one repo to personal:

```zsh
git-account set-repo personal ~/workspace/personal/dotfiles
```

Add a directory rule:

```zsh
git-account include work ~/workspace/work
git-account include personal ~/workspace/personal
```

Create SSH keys:

```zsh
git-account key work
git-account key personal
```

Use GitHub SSH host aliases:

```text
git@github.com-work:company/repo.git
git@github.com-personal:username/repo.git
```

Rewrite a remote:

```zsh
git-account remote work origin ~/workspace/wd-cron
```

## Runtime Versions

Use mise for language runtimes:

```zsh
mise use node@lts
mise use python@latest
mise use go@latest
mise use rust@latest
```

Install tools from a project config:

```zsh
mise install
```

See active versions:

```zsh
mise current
```

## Project Environments

Use direnv for per-project environment variables:

```zsh
cd my-project
echo 'export API_URL=http://localhost:3000' > .envrc
direnv allow
```

When you enter the directory, `.envrc` loads automatically.

## System And Disk

Process monitor:

```zsh
btop
```

Disk usage:

```zsh
dust
duf
```

Benchmark a command:

```zsh
hyperfine 'npm test' 'pnpm test'
```

## TUI Tools

Git:

```zsh
lazygit
lg
```

Docker:

```zsh
lazydocker
lzd
```

Kubernetes:

```zsh
k9s
k9
```

File manager:

```zsh
yazi
```

Terminal sessions:

```zsh
tmux
```

## Command Runner

Use `just` to keep project commands discoverable.

Example `justfile`:

```make
default:
    just --list

dev:
    npm run dev

test:
    npm test

lint:
    npm run lint
```

Run:

```zsh
just
just dev
just test
```

## Pretty Shell Scripts

Use `gum` for small interactive scripts:

```zsh
gum choose work personal
gum confirm "Continue?"
gum input --placeholder "Branch name"
```

## Health Checks

Check installed tools:

```zsh
devrepo
./scripts/doctor.sh
```

Check shell config syntax:

```zsh
devrepo
bash -n install.sh scripts/*.sh
zsh -n config/zsh/dev-setup.zsh
```

Check git status:

```zsh
devrepo
git status --short --branch
```

## Updating This Setup

Edit the guide:

```zsh
devhelp-edit
```

Edit shell aliases:

```zsh
devrepo
$EDITOR config/zsh/dev-setup.zsh
source ~/.zshrc
```

Add a new package:

```zsh
devrepo
$EDITOR Brewfile
brew bundle --file Brewfile
```

Commit changes:

```zsh
devrepo
git status --short
git add .
git commit -m "Update dev setup"
```

