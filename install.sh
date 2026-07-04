#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
NO_CASKS=0
SKIP_BREW=0
SKIP_SHELL=0
GIT_ACCOUNTS_MODE="ask"
BREW_GROUPS_MODE="ask"
BREW_GROUPS=""
BREW_SECTIONS="apps terminal shell modern logs code git network data containers cloud security media runtimes ai workflow"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$REPO_DIR/Brewfile"
ZSH_SNIPPET="$REPO_DIR/config/zsh/dev-setup.zsh"
STARSHIP_CONFIG="$REPO_DIR/config/starship/starship.toml"
GIT_CONFIG="$REPO_DIR/config/git/gitconfig"
GIT_ACCOUNT_SCRIPT="$REPO_DIR/scripts/git-accounts.sh"
NVIM_PROFILE_SCRIPT="$REPO_DIR/scripts/neovim-profiles.sh"
MENU_SCRIPT="$REPO_DIR/scripts/menu.sh"
LEARN_GUIDE="$REPO_DIR/docs/LEARN.md"
ZELLIJ_LAYOUT="$REPO_DIR/config/zellij/dev.kdl"
SELECTED_BREWFILE="$HOME/.config/dev-setup/Brewfile.selected"

load_repo_env() {
  local env_file="$REPO_DIR/.env"

  if [ -f "$env_file" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$env_file"
    set +a
  fi
}

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
  --list-tools   Show all Homebrew tools with descriptions
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
        BREW_GROUPS="$(printf '%s' "$BREW_SECTIONS" | tr ' ' ',')"
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
      --list-tools)
        list_brew_tools
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

Examples:
  ./install.sh --brew-groups apps,terminal,shell,modern
  ./install.sh --all-brew
  ./install.sh --brew-groups none
GROUPS
}

list_brew_tools() {
  local group
  local spec
  local label
  local description
  local recommended
  local kind

  printf 'Available Homebrew tools\n'
  printf 'Recommended: Y means included when the section default is recommended.\n\n'

  for group in $BREW_SECTIONS; do
    printf '%s\n' "$(section_title "$group")"
    printf '  %-6s %-32s %-3s %s\n' "kind" "tool" "rec" "description"

    while IFS='|' read -r spec label description recommended; do
      [ -n "$spec" ] || continue
      kind="${spec%%:*}"
      printf '  %-6s %-32s %-3s %s\n' "$kind" "$label" "$recommended" "$description"
    done < <(section_items "$group")

    printf '\n'
  done
}

is_brew_group() {
  case "$1" in
    apps|terminal|shell|modern|logs|code|git|network|data|containers|cloud|security|media|runtimes|ai|workflow|none) return 0 ;;
    *) return 1 ;;
  esac
}

section_title() {
  case "$1" in
    apps) printf 'Apps\n' ;;
    terminal) printf 'Terminal workspaces\n' ;;
    shell) printf 'Shell ergonomics\n' ;;
    modern) printf 'Modern Unix replacements\n' ;;
    logs) printf 'Logs, monitoring, and TUIs\n' ;;
    code) printf 'Code editing and quality\n' ;;
    git) printf 'Git extras\n' ;;
    network) printf 'Network and API diagnostics\n' ;;
    data) printf 'Data and file wrangling\n' ;;
    containers) printf 'Containers and Kubernetes\n' ;;
    cloud) printf 'Cloud and infrastructure\n' ;;
    security) printf 'Security and supply chain\n' ;;
    media) printf 'Media and documents\n' ;;
    runtimes) printf 'Language runtime helpers\n' ;;
    ai) printf 'Local and CLI AI tools\n' ;;
    workflow) printf 'Developer workflow helpers\n' ;;
  esac
}

section_default_choice() {
  case "$1" in
    network|data|containers|cloud|security|media|runtimes|ai) printf 'n\n' ;;
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
    terminal)
      cat <<'ITEMS'
brew:zellij|zellij|terminal workspace with tabs, panes, and layouts|Y
brew:tmux|tmux|classic terminal session manager|Y
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
ITEMS
      ;;
    code)
      cat <<'ITEMS'
brew:neovim|neovim|terminal editor, command is nvim|Y
brew:tokei|tokei|code statistics|Y
brew:ast-grep|ast-grep|AST-aware search and rewrite|Y
brew:typos-cli|typos-cli|source code spell checker|Y
brew:shellcheck|shellcheck|shell script linter|Y
brew:shfmt|shfmt|shell formatter|Y
brew:actionlint|actionlint|GitHub Actions linter|Y
brew:hadolint|hadolint|Dockerfile linter|N
brew:taplo|taplo|TOML formatter/linter|N
brew:yamllint|yamllint|YAML linter|N
brew:markdownlint-cli|markdownlint-cli|Markdown linter|N
ITEMS
      ;;
    git)
      cat <<'ITEMS'
brew:git-lfs|git-lfs|large file support for Git|Y
brew:pre-commit|pre-commit|manage Git hooks|Y
brew:git-extras|git-extras|extra Git subcommands|N
brew:git-filter-repo|git-filter-repo|rewrite Git history safely|Y
brew:difftastic|difftastic|syntax-aware diff viewer|Y
brew:jj|jj|Jujutsu version control|N
ITEMS
      ;;
    network)
      cat <<'ITEMS'
brew:wget|wget|file downloader|Y
brew:aria2|aria2|multi-protocol downloader|N
brew:doggo|doggo|DNS lookup client|Y
brew:gping|gping|ping with graph|Y
brew:mtr|mtr|traceroute and ping combined|N
brew:iperf3|iperf3|network throughput test|N
brew:nmap|nmap|network scanner|N
brew:bandwhich|bandwhich|bandwidth monitor|N
brew:trippy|trippy|network diagnostic TUI|N
ITEMS
      ;;
    data)
      cat <<'ITEMS'
brew:duckdb|duckdb|analytical SQL engine|Y
brew:sqlite|sqlite|SQLite CLI|Y
brew:miller|miller|CSV/JSON/TSV processor, command is mlr|Y
brew:csvkit|csvkit|CSV toolkit|N
brew:xsv|xsv|fast CSV toolkit|Y
brew:jless|jless|JSON viewer|Y
brew:fx|fx|JSON viewer/processor|Y
brew:dasel|dasel|query JSON/YAML/TOML/XML|N
brew:visidata|visidata|terminal data explorer|N
ITEMS
      ;;
    containers)
      cat <<'ITEMS'
brew:docker|docker|Docker CLI|Y
brew:docker-compose|docker-compose|Docker Compose CLI|Y
brew:colima|colima|container runtime for macOS|Y
brew:lazydocker|lazydocker|Docker TUI|Y
brew:kubectl|kubectl|Kubernetes CLI|Y
brew:helm|helm|Kubernetes package manager|Y
brew:kubectx|kubectx|switch Kubernetes contexts/namespaces|Y
brew:stern|stern|multi-pod log tailing|Y
brew:k9s|k9s|Kubernetes TUI|Y
brew:kind|kind|local Kubernetes clusters|N
brew:helmfile|helmfile|declarative Helm releases|N
ITEMS
      ;;
    cloud)
      cat <<'ITEMS'
brew:awscli|awscli|AWS CLI|N
brew:azure-cli|azure-cli|Azure CLI|N
brew:google-cloud-sdk|google-cloud-sdk|Google Cloud CLI|N
brew:doctl|doctl|DigitalOcean CLI|N
brew:flyctl|flyctl|Fly.io CLI|N
brew:opentofu|opentofu|Terraform-compatible IaC tool|Y
ITEMS
      ;;
    security)
      cat <<'ITEMS'
brew:gitleaks|gitleaks|secret scanner|Y
brew:trufflehog|trufflehog|verified secret scanner|N
brew:age|age|simple file encryption|Y
brew:sops|sops|encrypted secrets files|Y
brew:cosign|cosign|container signing and verification|N
brew:syft|syft|SBOM generator|N
brew:grype|grype|vulnerability scanner|N
ITEMS
      ;;
    media)
      cat <<'ITEMS'
brew:ffmpeg|ffmpeg|audio/video conversion|Y
brew:imagemagick|imagemagick|image conversion and editing|Y
brew:rclone|rclone|cloud storage sync|N
brew:pandoc|pandoc|document converter|Y
brew:poppler|poppler|PDF utilities|Y
brew:sevenzip|sevenzip|archive tool|Y
ITEMS
      ;;
    runtimes)
      cat <<'ITEMS'
brew:uv|uv|fast Python package/project tool|Y
brew:bun|bun|JavaScript runtime and package manager|N
brew:pnpm|pnpm|JavaScript package manager|Y
brew:deno|deno|JavaScript/TypeScript runtime|N
ITEMS
      ;;
    ai)
      cat <<'ITEMS'
cask:claude-code|Claude Code|terminal-based AI coding assistant, command is claude|Y
brew:ollama|ollama|local model runner|N
brew:llm|llm|LLM CLI and plugin ecosystem|N
brew:aichat|aichat|AI chat CLI|N
brew:mods|mods|AI assistant for pipelines|N
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
  local total

  if [ "$BREW_GROUPS_MODE" = "custom" ]; then
    groups="$(printf '%s' "$BREW_GROUPS" | tr ',' ' ')"
  elif [ -t 0 ]; then
    printf '\nChoose Homebrew tools by section.\n' >&2
    printf 'Each section lets you pick recommended, all, skip, or custom.\n' >&2

    # shellcheck disable=SC2086
    set -- $BREW_SECTIONS
    total="$#"
    for group in $BREW_SECTIONS; do
      select_brew_section "$group" "$index" "$total"
      index=$((index + 1))
    done
    return
  else
    groups="apps terminal shell modern logs code git workflow"
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
    run mkdir -p "$(dirname "$SELECTED_BREWFILE")"
    if [ "$DRY_RUN" -eq 1 ]; then
      warn "Would write empty selected Brewfile to $SELECTED_BREWFILE"
    else
      printf '# Generated by install.sh\n# No Homebrew tools selected\n' > "$SELECTED_BREWFILE"
    fi
    log "Skipping Homebrew bundle"
    return
  fi

  tmp_file="$(mktemp)"
  write_selected_brewfile "$tmp_file" "$selected_specs"
  bundle_file="$tmp_file"

  run mkdir -p "$(dirname "$SELECTED_BREWFILE")"
  run cp "$bundle_file" "$SELECTED_BREWFILE"

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
  link_file "$NVIM_PROFILE_SCRIPT" "$HOME/.local/bin/nvim-profile"
  link_file "$MENU_SCRIPT" "$HOME/.local/bin/dev-setup"
  link_file "$ZELLIJ_LAYOUT" "$HOME/.config/zellij/layouts/dev.kdl"
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
  load_repo_env
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
