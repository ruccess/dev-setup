#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
NO_CASKS=0
SKIP_BREW=0
SKIP_SHELL=0
GIT_ACCOUNTS_MODE="ask"
BREW_GROUPS_MODE="ask"
BREW_GROUPS=""

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
  --all-brew      Install all Homebrew groups without prompting
  --brew-groups GROUPS
                 Install comma-separated groups without prompting
  --list-brew-groups
                 Show available Homebrew groups
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
      --all-brew)
        BREW_GROUPS_MODE="custom"
        BREW_GROUPS="apps,shell,modern,logs,containers,workflow"
        ;;
      --brew-groups)
        shift
        [ "$#" -gt 0 ] || {
          printf 'Missing value for --brew-groups\n' >&2
          exit 1
        }
        BREW_GROUPS_MODE="custom"
        BREW_GROUPS="$1"
        ;;
      --list-brew-groups)
        list_brew_groups
        exit 0
        ;;
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

list_brew_groups() {
  cat <<'GROUPS'
Available Homebrew sections:

  apps        Ghostty, Raycast, JetBrains Mono Nerd Font
  shell       starship, fzf, zoxide, atuin, mise, direnv
  modern      eza, bat, fd, ripgrep, sd, jq, yq, dust, duf, git-delta
  logs        lnav, tailspin, btop, lazygit, yazi, tmux
  containers  lazydocker, k9s
  workflow    gh, just, gum, hyperfine, xh

Examples:
  ./install.sh --brew-groups apps,shell,modern
  ./install.sh --all-brew
  ./install.sh --brew-groups none
GROUPS
}

is_brew_group() {
  case "$1" in
    apps|shell|modern|logs|containers|workflow|none) return 0 ;;
    *) return 1 ;;
  esac
}

section_title() {
  case "$1" in
    apps) printf 'Apps\n' ;;
    shell) printf 'Shell ergonomics\n' ;;
    modern) printf 'Modern Unix replacements\n' ;;
    logs) printf 'Logs, monitoring, and TUIs\n' ;;
    containers) printf 'Containers and Kubernetes\n' ;;
    workflow) printf 'Developer workflow helpers\n' ;;
  esac
}

section_default_choice() {
  case "$1" in
    containers) printf 'n\n' ;;
    *) printf 'r\n' ;;
  esac
}

section_items() {
  case "$1" in
    apps)
      cat <<'ITEMS'
cask:ghostty|Ghostty|fast terminal app|Y
cask:raycast|Raycast|launcher and command palette|Y
cask:font-jetbrains-mono-nerd-font|JetBrains Mono Nerd Font|terminal font with icons|Y
ITEMS
      ;;
    shell)
      cat <<'ITEMS'
brew:starship|starship|fast prompt|Y
brew:fzf|fzf|fuzzy finder|Y
brew:zoxide|zoxide|smarter cd|Y
brew:atuin|atuin|searchable shell history|Y
brew:mise|mise|runtime version manager|Y
brew:direnv|direnv|per-project env loader|Y
ITEMS
      ;;
    modern)
      cat <<'ITEMS'
brew:eza|eza|ls replacement|Y
brew:bat|bat|cat with syntax highlighting|Y
brew:fd|fd|find replacement|Y
brew:ripgrep|ripgrep|grep replacement, command is rg|Y
brew:sd|sd|simple string replacement|Y
brew:jq|jq|JSON processor|Y
brew:yq|yq|YAML/JSON/XML processor|Y
brew:dust|dust|disk usage viewer|Y
brew:duf|duf|disk free viewer|Y
brew:git-delta|git-delta|better git diff pager|Y
ITEMS
      ;;
    logs)
      cat <<'ITEMS'
brew:lnav|lnav|log viewer|Y
brew:tailspin|tailspin|log highlighter, command is tspin|Y
brew:btop|btop|system monitor|Y
brew:lazygit|lazygit|Git TUI|Y
brew:yazi|yazi|terminal file manager|Y
brew:tmux|tmux|terminal session manager|Y
ITEMS
      ;;
    containers)
      cat <<'ITEMS'
brew:lazydocker|lazydocker|Docker TUI|Y
brew:k9s|k9s|Kubernetes TUI|Y
ITEMS
      ;;
    workflow)
      cat <<'ITEMS'
brew:gh|gh|GitHub CLI|Y
brew:just|just|project command runner|Y
brew:gum|gum|interactive shell script UI|Y
brew:hyperfine|hyperfine|command benchmarker|Y
brew:xh|xh|HTTP client|Y
ITEMS
      ;;
  esac
}

read_from_tty() {
  if [ -r /dev/tty ]; then
    read -r "$1" < /dev/tty
  else
    read -r "$1"
  fi
}

ask_yes_no() {
  local label="$1"
  local default="${2:-Y}"
  local answer
  local suffix

  if [ "$default" = "Y" ]; then
    suffix="Y/n"
  else
    suffix="y/N"
  fi

  printf '%s [%s]: ' "$label" "$suffix" >&2
  read_from_tty answer
  answer="${answer:-$default}"

  case "$answer" in
    Y|y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

print_section_items() {
  local group="$1"
  local i=1
  local spec
  local label
  local description
  local recommended

  while IFS='|' read -r spec label description recommended; do
    [ -n "$spec" ] || continue
    printf '  %s. %-28s %s\n' "$i" "$label" "$description" >&2
    i=$((i + 1))
  done < <(section_items "$group")
}

emit_section_recommended() {
  local group="$1"
  local spec
  local label
  local description
  local recommended

  while IFS='|' read -r spec label description recommended; do
    [ -n "$spec" ] || continue
    [ "$recommended" = "Y" ] && printf '%s\n' "$spec"
  done < <(section_items "$group")
}

emit_section_all() {
  local group="$1"
  local spec
  local label
  local description
  local recommended

  while IFS='|' read -r spec label description recommended; do
    [ -n "$spec" ] || continue
    printf '%s\n' "$spec"
  done < <(section_items "$group")
}

emit_section_custom() {
  local group="$1"
  local spec
  local label
  local description
  local recommended

  while IFS='|' read -r spec label description recommended; do
    [ -n "$spec" ] || continue
    if ask_yes_no "  Install $label? $description" "$recommended"; then
      printf '%s\n' "$spec"
    fi
  done < <(section_items "$group")
}

select_brew_section() {
  local group="$1"
  local index="$2"
  local total="$3"
  local default_choice
  local choice

  default_choice="$(section_default_choice "$group")"

  printf '\n[%s/%s] %s\n' "$index" "$total" "$(section_title "$group")" >&2
  print_section_items "$group"
  printf '\n' >&2

  while true; do
    printf 'Choose: Enter=%s, r=recommended, a=all, n=skip, c=custom: ' "$default_choice" >&2
    read_from_tty choice
    choice="${choice:-$default_choice}"

    case "$choice" in
      r|R|recommended)
        emit_section_recommended "$group"
        return
        ;;
      a|A|all)
        emit_section_all "$group"
        return
        ;;
      n|N|none|skip)
        return
        ;;
      c|C|custom)
        emit_section_custom "$group"
        return
        ;;
      *)
        warn "Choose r, a, n, or c"
        ;;
    esac
  done
}

emit_group_specs() {
  local group="$1"

  if ! is_brew_group "$group"; then
    printf 'Unknown Homebrew section: %s\n\n' "$group" >&2
    list_brew_groups >&2
    exit 1
  fi

  if [ "$group" = "none" ]; then
    printf 'none\n'
    return
  fi

  emit_section_all "$group"
}

select_brew_specs() {
  local selected=""
  local groups
  local group
  local index=1
  local total=6

  if [ "$BREW_GROUPS_MODE" = "custom" ]; then
    groups="$(printf '%s' "$BREW_GROUPS" | tr ',' ' ')"
  elif [ -t 0 ]; then
    printf '\nChoose Homebrew tools by section.\n' >&2
    printf 'Each section lets you pick recommended, all, skip, or custom.\n' >&2

    for group in apps shell modern logs containers workflow; do
      select_brew_section "$group" "$index" "$total"
      index=$((index + 1))
    done
    return
  else
    groups="apps shell modern logs workflow"
  fi

  selected=""
  for group in $groups; do
    if [ "$group" = "none" ]; then
      printf 'none\n'
      return
    fi
    emit_group_specs "$group"
  done
}

append_brew_spec() {
  local output="$1"
  local spec="$2"
  local kind
  local name

  [ -n "$spec" ] || return

  kind="${spec%%:*}"
  name="${spec#*:}"

  case "$kind" in
    cask)
      if [ "$NO_CASKS" -eq 0 ]; then
        printf 'cask "%s"\n' "$name" >> "$output"
      else
        printf '# skipped cask "%s" due to --no-casks\n' "$name" >> "$output"
      fi
      ;;
    brew)
      printf 'brew "%s"\n' "$name" >> "$output"
      ;;
    *)
      die "unknown Homebrew spec: $spec"
      ;;
  esac
}

write_selected_brewfile() {
  local output="$1"
  local specs="$2"
  local spec
  local seen=""

  {
    printf '# Generated by install.sh\n'
    printf '# Selected Homebrew tools\n\n'
  } > "$output"

  while IFS= read -r spec; do
    [ -n "$spec" ] || continue
    [ "$spec" = "none" ] && continue
    case "$seen" in
      *"|$spec|"*) continue ;;
    esac
    seen="$seen|$spec|"
    append_brew_spec "$output" "$spec"
  done <<EOF
$specs
EOF
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

  local selected_specs
  local bundle_file
  local tmp_file

  selected_specs="$(select_brew_specs)"

  if [ "$selected_specs" = "none" ] || [ -z "$selected_specs" ]; then
    log "Skipping Homebrew bundle"
    return
  fi

  tmp_file="$(mktemp)"
  write_selected_brewfile "$tmp_file" "$selected_specs"
  bundle_file="$tmp_file"

  log "Installing selected Homebrew tools"
  run brew bundle --file "$bundle_file"

  rm -f "$tmp_file"
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
