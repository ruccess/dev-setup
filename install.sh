#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
NO_CASKS=0
SKIP_BREW=0
SKIP_SHELL=0
GIT_ACCOUNTS_MODE="ask"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$REPO_DIR/Brewfile"
ZSH_SNIPPET="$REPO_DIR/config/zsh/dev-setup.zsh"
STARSHIP_CONFIG="$REPO_DIR/config/starship/starship.toml"
GIT_CONFIG="$REPO_DIR/config/git/gitconfig"
GIT_ACCOUNT_SCRIPT="$REPO_DIR/scripts/git-accounts.sh"
LEARN_GUIDE="$REPO_DIR/docs/LEARN.md"

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --dry-run      Print actions without changing files
  --no-casks     Skip Homebrew cask apps
  --skip-brew    Skip Homebrew bundle install
  --skip-shell   Skip zsh/config/git setup
  --git-accounts Configure Git accounts during install
  --skip-git-accounts
                 Do not ask to configure Git accounts
  -h, --help     Show this help
USAGE
}

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'dry-run:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --no-casks) NO_CASKS=1 ;;
      --skip-brew) SKIP_BREW=1 ;;
      --skip-shell) SKIP_SHELL=1 ;;
      --git-accounts) GIT_ACCOUNTS_MODE="yes" ;;
      --skip-git-accounts) GIT_ACCOUNTS_MODE="no" ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return
  fi

  if [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return
  fi

  log "Installing Homebrew"
  if [ "$DRY_RUN" -eq 1 ]; then
    warn "Homebrew is missing; would run official installer"
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_bundle() {
  [ "$SKIP_BREW" -eq 1 ] && return

  ensure_homebrew

  local bundle_file="$BREWFILE"
  local tmp_file=""

  if [ "$NO_CASKS" -eq 1 ]; then
    tmp_file="$(mktemp)"
    grep -v '^cask ' "$BREWFILE" > "$tmp_file"
    bundle_file="$tmp_file"
  fi

  log "Installing Homebrew bundle"
  run brew bundle --file "$bundle_file"

  if [ -n "$tmp_file" ]; then
    rm -f "$tmp_file"
  fi
}

backup_path() {
  local target="$1"
  local backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  run mv "$target" "$backup"
  warn "Backed up $target to $backup"
}

link_file() {
  local source="$1"
  local target="$2"
  local target_dir

  target_dir="$(dirname "$target")"
  run mkdir -p "$target_dir"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    log "Already linked $target"
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_path "$target"
  fi

  log "Linking $target"
  run ln -s "$source" "$target"
}

install_zshrc_block() {
  local zshrc="${ZDOTDIR:-$HOME}/.zshrc"
  local begin="# >>> dev-setup >>>"
  local end="# <<< dev-setup <<<"
  local tmp_file

  log "Installing zsh managed block"

  if [ "$DRY_RUN" -eq 1 ]; then
    warn "Would update $zshrc"
    return
  fi

  touch "$zshrc"
  cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d%H%M%S)"
  tmp_file="$(mktemp)"

  awk -v begin="$begin" -v end="$end" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "$zshrc" > "$tmp_file"

  {
    printf '\n%s\n' "$begin"
    printf 'if [ -f "$HOME/.config/dev-setup/dev-setup.zsh" ]; then\n'
    printf '  source "$HOME/.config/dev-setup/dev-setup.zsh"\n'
    printf 'fi\n'
    printf '%s\n' "$end"
  } >> "$tmp_file"

  mv "$tmp_file" "$zshrc"
}

install_git_include() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git not found; skipping git config include"
    return
  fi

  while IFS= read -r include_path; do
    if [ "$include_path" != "$GIT_CONFIG" ] && [[ "$include_path" == */dev-setup/config/git/gitconfig ]]; then
      log "Removing stale git config include: $include_path"
      run git config --global --unset-all include.path "$include_path"
    fi
  done < <(git config --global --get-all include.path 2>/dev/null || true)

  if git config --global --get-all include.path 2>/dev/null | grep -Fxq "$GIT_CONFIG"; then
    log "Git config include already present"
    return
  fi

  log "Adding git config include"
  run git config --global --add include.path "$GIT_CONFIG"
}

install_shell_configs() {
  [ "$SKIP_SHELL" -eq 1 ] && return

  link_file "$ZSH_SNIPPET" "$HOME/.config/dev-setup/dev-setup.zsh"
  link_file "$LEARN_GUIDE" "$HOME/.config/dev-setup/LEARN.md"
  link_file "$REPO_DIR" "$HOME/.config/dev-setup/repo"
  link_file "$STARSHIP_CONFIG" "$HOME/.config/starship.toml"
  link_file "$GIT_ACCOUNT_SCRIPT" "$HOME/.local/bin/git-account"
  install_zshrc_block
  install_git_include
}

configure_git_accounts() {
  [ "$SKIP_SHELL" -eq 1 ] && return
  [ "$GIT_ACCOUNTS_MODE" = "no" ] && return

  if [ "$DRY_RUN" -eq 1 ]; then
    warn "Would ask whether to configure Git accounts"
    return
  fi

  if [ "$GIT_ACCOUNTS_MODE" = "yes" ]; then
    "$GIT_ACCOUNT_SCRIPT" init
    return
  fi

  if [ ! -t 0 ] || [ ! -t 1 ]; then
    return
  fi

  local existing_accounts=""
  if [ -d "$HOME/.config/dev-setup/git/accounts" ]; then
    existing_accounts="$(find "$HOME/.config/dev-setup/git/accounts" -maxdepth 1 -type f -name '*.gitconfig' -print -quit 2>/dev/null || true)"
  fi

  local prompt="Configure Git accounts now?"
  local default="Y"
  if [ -n "$existing_accounts" ]; then
    prompt="Reconfigure Git accounts now?"
    default="N"
  fi

  local answer
  local suffix
  if [ "$default" = "Y" ]; then
    suffix="Y/n"
  else
    suffix="y/N"
  fi

  read -r -p "$prompt [$suffix]: " answer
  answer="${answer:-$default}"

  case "$answer" in
    Y|y|yes|YES) "$GIT_ACCOUNT_SCRIPT" init ;;
    *) log "Skipping Git account setup" ;;
  esac
}

install_fzf_extras() {
  [ "$SKIP_BREW" -eq 1 ] && return

  local fzf_install=""

  if command -v brew >/dev/null 2>&1; then
    fzf_install="$(brew --prefix)/opt/fzf/install"
  fi

  if [ -x "$fzf_install" ]; then
    log "Installing fzf key bindings and completion"
    run "$fzf_install" --key-bindings --completion --no-update-rc --no-bash --no-fish
  fi
}

main() {
  parse_args "$@"
  brew_bundle
  install_fzf_extras
  install_shell_configs
  configure_git_accounts

  log "Done"
  printf 'Open a new terminal or run: source ~/.zshrc\n'
  printf 'Then run: ./scripts/doctor.sh\n'
}

main "$@"
