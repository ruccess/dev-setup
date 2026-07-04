#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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
Usage: dev-setup-menu [options]

Options:
  --list      List available menu actions
  -h, --help  Show this help

Run without options to open the interactive menu.
USAGE
}

has_gum() {
  command -v gum >/dev/null 2>&1
}

choose_one() {
  local prompt="$1"
  shift

  if has_gum; then
    gum choose --header "$prompt" "$@"
    return
  fi

  local i=1
  local choice
  local item

  printf '\n%s\n' "$prompt" >&2
  for item in "$@"; do
    printf '  %s) %s\n' "$i" "$item" >&2
    i=$((i + 1))
  done

  while true; do
    printf 'Choose number: ' >&2
    read -r choice
    case "$choice" in
      ''|*[!0-9]*) printf 'Enter a number.\n' >&2 ;;
      *)
        if [ "$choice" -ge 1 ] && [ "$choice" -le "$#" ]; then
          eval "printf '%s\n' \"\${$choice}\""
          return
        fi
        printf 'Choose 1-%s.\n' "$#" >&2
        ;;
    esac
  done
}

confirm() {
  local prompt="$1"
  local answer

  if has_gum; then
    gum confirm "$prompt"
    return
  fi

  printf '%s [y/N]: ' "$prompt"
  read -r answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

pause() {
  printf '\nPress Enter to continue...'
  read -r _
}

run_cmd() {
  local status

  printf '\n$'
  printf ' %q' "$@"
  printf '\n\n'

  set +e
  "$@"
  status="$?"
  set -e

  if [ "$status" -ne 0 ]; then
    printf '\nCommand exited with status %s.\n' "$status" >&2
  fi

  return 0
}

open_file() {
  local file="$1"

  if command -v bat >/dev/null 2>&1; then
    bat --paging=always "$file"
  else
    less "$file"
  fi
}

list_actions() {
  cat <<'ACTIONS'
list Homebrew sections
tool catalog
choose tools dry-run
choose tools and install
doctor
Git accounts
GitHub CLI
Neovim profiles
Zellij dev workspace
open LEARN.md
open SKILL.md
script explorer
ACTIONS
}

action_install_dry_run() {
  run_cmd "$REPO_DIR/install.sh" --dry-run --skip-git-accounts
}

action_install_choose() {
  if confirm "Choose tools section-by-section and install the selected tools now?"; then
    run_cmd "$REPO_DIR/install.sh" --skip-git-accounts
  fi
}

action_git_accounts() {
  local choice

  choice="$(choose_one "Git accounts" \
    "init/reconfigure accounts" \
    "list accounts" \
    "show current repo account" \
    "create SSH key for an account" \
    "rewrite current repo origin remote" \
    "back")"

  case "$choice" in
    "init/reconfigure accounts")
      run_cmd "$REPO_DIR/scripts/git-accounts.sh" init
      ;;
    "list accounts")
      run_cmd "$REPO_DIR/scripts/git-accounts.sh" list
      ;;
    "show current repo account")
      run_cmd "$REPO_DIR/scripts/git-accounts.sh" current "$PWD"
      ;;
    "create SSH key for an account")
      local account
      printf 'Account id: '
      read -r account
      [ -n "$account" ] && run_cmd "$REPO_DIR/scripts/git-accounts.sh" key "$account"
      ;;
    "rewrite current repo origin remote")
      local account
      printf 'Account id: '
      read -r account
      [ -n "$account" ] && run_cmd "$REPO_DIR/scripts/git-accounts.sh" remote "$account" origin "$PWD"
      ;;
  esac
}

action_github_cli() {
  local choice

  if ! command -v gh >/dev/null 2>&1; then
    printf 'gh is not installed yet. Install the workflow section first.\n' >&2
    return 0
  fi

  choice="$(choose_one "GitHub CLI" \
    "auth status" \
    "login" \
    "open current repo in browser" \
    "list pull requests" \
    "list workflows" \
    "back")"

  case "$choice" in
    "auth status")
      run_cmd gh auth status
      ;;
    "login")
      run_cmd gh auth login
      ;;
    "open current repo in browser")
      run_cmd gh repo view --web
      ;;
    "list pull requests")
      run_cmd gh pr list
      ;;
    "list workflows")
      run_cmd gh workflow list
      ;;
  esac
}

action_neovim_profiles() {
  local choice

  choice="$(choose_one "Neovim profiles" \
    "list profiles" \
    "install LazyVim" \
    "install AstroNvim" \
    "install NvChad" \
    "open LazyVim here" \
    "open AstroNvim here" \
    "open NvChad here" \
    "back")"

  case "$choice" in
    "list profiles")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" list
      ;;
    "install LazyVim")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" install lazyvim
      ;;
    "install AstroNvim")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" install astronvim
      ;;
    "install NvChad")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" install nvchad
      ;;
    "open LazyVim here")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" open lazyvim .
      ;;
    "open AstroNvim here")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" open astronvim .
      ;;
    "open NvChad here")
      run_cmd "$REPO_DIR/scripts/neovim-profiles.sh" open nvchad .
      ;;
  esac
}

script_label() {
  local script="$1"

  case "$(basename "$script")" in
    doctor.sh) printf 'doctor.sh - 설치 상태 점검\n' ;;
    git-accounts.sh) printf 'git-accounts.sh - Git 계정/SSH 관리\n' ;;
    menu.sh) printf 'menu.sh - dev-setup 선택 메뉴\n' ;;
    neovim-profiles.sh) printf 'neovim-profiles.sh - Neovim 프로필 관리\n' ;;
    *) printf '%s\n' "$(basename "$script")" ;;
  esac
}

show_script_help() {
  local script="$1"

  case "$(basename "$script")" in
    doctor.sh)
      printf 'Usage: %s\n' "$script"
      ;;
    *)
      "$script" --help 2>/dev/null || "$script" help 2>/dev/null || "$script" 2>/dev/null || true
      ;;
  esac
}

action_script_explorer() {
  local scripts=("$REPO_DIR/install.sh")
  local script
  local label
  local labels=()
  local choice
  local selected=""
  local action

  while IFS= read -r script; do
    scripts+=("$script")
  done < <(find "$REPO_DIR/scripts" -maxdepth 1 -type f -name '*.sh' | sort)

  for script in "${scripts[@]}"; do
    if [ "$(basename "$script")" = "install.sh" ]; then
      label="install.sh - 설치/링크 bootstrap"
    else
      label="$(script_label "$script")"
    fi
    labels+=("$label")
  done
  labels+=("back")

  choice="$(choose_one "Scripts" "${labels[@]}")"
  [ "$choice" = "back" ] && return

  for script in "${scripts[@]}"; do
    if [ "$(basename "$script")" = "install.sh" ]; then
      label="install.sh - 설치/링크 bootstrap"
    else
      label="$(script_label "$script")"
    fi
    if [ "$choice" = "$label" ]; then
      selected="$script"
      break
    fi
  done

  [ -n "$selected" ] || return

  action="$(choose_one "$(basename "$selected")" "show help/usage" "run script" "open in editor" "back")"
  case "$action" in
    "show help/usage")
      show_script_help "$selected"
      ;;
    "run script")
      if confirm "Run $(basename "$selected") now?"; then
        run_cmd "$selected"
      fi
      ;;
    "open in editor")
      "${EDITOR:-vim}" "$selected"
      ;;
  esac
}

action_zellij() {
  local layout="$REPO_DIR/config/zellij/dev.kdl"

  if ! command -v zellij >/dev/null 2>&1; then
    printf 'zellij is not installed yet. Install the terminal section first.\n' >&2
    return 0
  fi

  run_cmd zellij --layout "$layout"
}

main_menu() {
  local choice

  while true; do
    choice="$(choose_one "dev-setup" \
      "list Homebrew sections" \
      "tool catalog" \
      "choose tools dry-run" \
      "choose tools and install" \
      "doctor" \
      "Git accounts" \
      "GitHub CLI" \
      "Neovim profiles" \
      "Zellij dev workspace" \
      "open LEARN.md" \
      "open SKILL.md" \
      "script explorer" \
      "quit")"

    case "$choice" in
      "list Homebrew sections") run_cmd "$REPO_DIR/install.sh" --list-brew-groups ;;
      "tool catalog") run_cmd "$REPO_DIR/install.sh" --list-tools ;;
      "choose tools dry-run") action_install_dry_run ;;
      "choose tools and install") action_install_choose ;;
      "doctor") run_cmd "$REPO_DIR/scripts/doctor.sh" ;;
      "Git accounts") action_git_accounts ;;
      "GitHub CLI") action_github_cli ;;
      "Neovim profiles") action_neovim_profiles ;;
      "Zellij dev workspace") action_zellij ;;
      "open LEARN.md") open_file "$REPO_DIR/docs/LEARN.md" ;;
      "open SKILL.md") open_file "$REPO_DIR/SKILL.md" ;;
      "script explorer") action_script_explorer ;;
      "quit") return ;;
    esac

    pause
  done
}

main() {
  load_repo_env

  case "${1:-}" in
    --list)
      list_actions
      ;;
    -h|--help)
      usage
      ;;
    "")
      main_menu
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
