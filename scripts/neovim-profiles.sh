#!/usr/bin/env bash
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

usage() {
  cat <<'USAGE'
Usage: nvim-profile <command> [args]

Commands:
  list
      Show supported Neovim starter profiles.

  install <lazyvim|astronvim|nvchad> [appname]
      Clone a starter config into ~/.config/<appname>.
      The default appname is the profile name, so your normal ~/.config/nvim
      is not overwritten.

  open <appname> [nvim args...]
      Open Neovim with NVIM_APPNAME=<appname>.

  path <appname>
      Print the config path for an appname.

Examples:
  nvim-profile install lazyvim
  nvim-profile open lazyvim .
  NVIM_APPNAME=lazyvim nvim .
USAGE
}

profile_repo() {
  case "$1" in
    lazyvim) printf 'https://github.com/LazyVim/starter\n' ;;
    astronvim) printf 'https://github.com/AstroNvim/template\n' ;;
    nvchad) printf 'https://github.com/NvChad/starter\n' ;;
    *)
      printf 'Unknown profile: %s\n' "$1" >&2
      printf 'Supported profiles: lazyvim, astronvim, nvchad\n' >&2
      return 1
      ;;
  esac
}

profile_description() {
  case "$1" in
    lazyvim) printf 'balanced IDE-like defaults, easiest recommendation\n' ;;
    astronvim) printf 'feature-rich and extensible IDE-style setup\n' ;;
    nvchad) printf 'fast, polished UI with lean defaults\n' ;;
  esac
}

config_path() {
  local appname="$1"
  printf '%s/%s\n' "$CONFIG_HOME" "$appname"
}

cmd_list() {
  local profile

  printf '%-10s %s\n' "profile" "description"
  printf '%-10s %s\n' "-------" "-----------"
  for profile in lazyvim astronvim nvchad; do
    printf '%-10s %s\n' "$profile" "$(profile_description "$profile")"
  done
}

cmd_install() {
  local profile="${1:-}"
  local appname="${2:-${1:-}}"
  local repo
  local target

  if [ -z "$profile" ]; then
    usage >&2
    exit 1
  fi

  repo="$(profile_repo "$profile")"
  target="$(config_path "$appname")"

  if [ -e "$target" ]; then
    printf 'Config already exists: %s\n' "$target" >&2
    printf 'Pick another appname or move that directory first.\n' >&2
    exit 1
  fi

  mkdir -p "$CONFIG_HOME"
  git clone --depth 1 "$repo" "$target"
  rm -rf "$target/.git"

  printf 'Installed %s at %s\n' "$profile" "$target"
  printf 'Open it with: NVIM_APPNAME=%s nvim\n' "$appname"
}

cmd_open() {
  local appname="${1:-}"

  if [ -z "$appname" ]; then
    usage >&2
    exit 1
  fi

  shift
  NVIM_APPNAME="$appname" nvim "$@"
}

main() {
  local command="${1:-}"

  case "$command" in
    list)
      cmd_list
      ;;
    install)
      shift
      cmd_install "$@"
      ;;
    open)
      shift
      cmd_open "$@"
      ;;
    path)
      shift
      [ "${1:-}" ] || {
        usage >&2
        exit 1
      }
      config_path "$1"
      ;;
    -h|--help|help|"")
      usage
      ;;
    *)
      printf 'Unknown command: %s\n\n' "$command" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
