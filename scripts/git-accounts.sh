#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_DIR="${DEV_SETUP_GIT_ACCOUNT_DIR:-$HOME/.config/dev-setup/git/accounts}"
SSH_CONFIG="${DEV_SETUP_SSH_CONFIG:-$HOME/.ssh/config}"
WELDA_DIR_DEFAULT="${DEV_SETUP_WELDA_DIR:-$HOME/workspace/welda}"
RUCESS_DIR_DEFAULT="${DEV_SETUP_RUCESS_DIR:-$HOME/workspace/ruccess}"

SSH_BEGIN="# >>> dev-setup git accounts >>>"
SSH_END="# <<< dev-setup git accounts <<<"

usage() {
  cat <<'USAGE'
Usage: git-account <command> [args]

Commands:
  init                         Create local welda/ruccess configs and directory includes
  current [repo]               Show the Git identity active for a repo
  set-repo <welda|ruccess> [repo]
                               Pin one repo to an account with local include.path
  include <welda|ruccess> <dir>
                               Add a global includeIf rule for a directory
  ssh-config                   Install managed GitHub SSH host aliases
  key <welda|ruccess>          Create an ed25519 SSH key for an account
  remote <welda|ruccess> [remote] [repo]
                               Rewrite a GitHub remote to use the account SSH alias
  help                         Show this help

Examples:
  git-account init
  git-account current
  git-account set-repo welda ~/workspace/welda/api
  git-account remote ruccess origin ~/workspace/ruccess/dev-setup

SSH remotes:
  git@github.com-welda:welda/repo.git
  git@github.com-ruccess:ruccess/repo.git
USAGE
}

log() {
  printf '\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

account_config() {
  case "${1:-}" in
    welda|work|company) printf '%s/welda.gitconfig\n' "$ACCOUNT_DIR" ;;
    ruccess|personal) printf '%s/ruccess.gitconfig\n' "$ACCOUNT_DIR" ;;
    *) die "unknown account: ${1:-} (use welda or ruccess)" ;;
  esac
}

account_name() {
  case "${1:-}" in
    welda|work|company) printf 'welda\n' ;;
    ruccess|personal) printf 'ruccess\n' ;;
    *) die "unknown account: ${1:-} (use welda or ruccess)" ;;
  esac
}

host_alias() {
  case "$(account_name "$1")" in
    welda) printf 'github.com-welda\n' ;;
    ruccess) printf 'github.com-ruccess\n' ;;
  esac
}

key_path() {
  case "$(account_name "$1")" in
    welda) printf '%s/.ssh/id_ed25519_welda\n' "$HOME" ;;
    ruccess) printf '%s/.ssh/id_ed25519_ruccess\n' "$HOME" ;;
  esac
}

prompt() {
  local label="$1"
  local default="${2:-}"
  local value

  if [ -n "$default" ]; then
    read -r -p "$label [$default]: " value
    printf '%s\n' "${value:-$default}"
  else
    read -r -p "$label: " value
    printf '%s\n' "$value"
  fi
}

prompt_required() {
  local label="$1"
  local default="${2:-}"
  local value=""

  while [ -z "$value" ]; do
    value="$(prompt "$label" "$default")"
    if [ -z "$value" ]; then
      warn "$label is required"
    fi
  done

  printf '%s\n' "$value"
}

write_account_config() {
  local account="$1"
  local name="$2"
  local email="$3"
  local github_user="$4"
  local config

  config="$(account_config "$account")"
  mkdir -p "$ACCOUNT_DIR"

  cat > "$config" <<EOF
[user]
	name = $name
	email = $email

[github]
	user = $github_user
EOF

  chmod 600 "$config"
  log "Wrote $config"
}

ensure_global_include() {
  local dir="$1"
  local config="$2"
  local normalized="$dir"
  local key

  normalized="${normalized%/}/"

  if ! mkdir -p "$normalized" 2>/dev/null; then
    warn "Could not create $normalized; adding include rule anyway"
  fi

  case "$normalized" in
    "$HOME"/*) normalized="~/${normalized#"$HOME"/}" ;;
  esac

  key="includeIf.gitdir:$normalized.path"

  if git config --global --get-all "$key" 2>/dev/null | grep -Fxq "$config"; then
    log "Git include already present for $normalized"
    return
  fi

  git config --global --add "$key" "$config"
  log "Added Git include for $normalized"
}

install_ssh_config() {
  local dir
  local tmp

  dir="$(dirname "$SSH_CONFIG")"
  mkdir -p "$dir"
  touch "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  tmp="$(mktemp)"

  awk -v begin="$SSH_BEGIN" -v end="$SSH_END" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "$SSH_CONFIG" > "$tmp"

  {
    printf '\n%s\n' "$SSH_BEGIN"
    printf 'Host github.com-welda github.com-work\n'
    printf '  HostName github.com\n'
    printf '  User git\n'
    printf '  IdentityFile ~/.ssh/id_ed25519_welda\n'
    printf '  IdentitiesOnly yes\n'
    printf '\n'
    printf 'Host github.com-ruccess github.com-personal\n'
    printf '  HostName github.com\n'
    printf '  User git\n'
    printf '  IdentityFile ~/.ssh/id_ed25519_ruccess\n'
    printf '  IdentitiesOnly yes\n'
    printf '%s\n' "$SSH_END"
  } >> "$tmp"

  mv "$tmp" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  log "Installed SSH host aliases in $SSH_CONFIG"
}

init_accounts() {
  local default_name
  local default_email
  local welda_name
  local welda_email
  local welda_user
  local ruccess_name
  local ruccess_email
  local ruccess_user
  local welda_dir
  local ruccess_dir

  default_name="$(git config --global --get user.name 2>/dev/null || true)"
  default_email="$(git config --global --get user.email 2>/dev/null || true)"

  printf 'Welda account\n'
  welda_name="$(prompt_required '  Git name' "$default_name")"
  welda_email="$(prompt_required '  Git email' "$default_email")"
  welda_user="$(prompt '  GitHub username/org login' 'welda')"
  printf '\nRuccess account\n'
  ruccess_name="$(prompt_required '  Git name' "$default_name")"
  ruccess_email="$(prompt_required '  Git email' '')"
  ruccess_user="$(prompt '  GitHub username' 'ruccess')"
  printf '\nDirectories\n'
  welda_dir="$(prompt_required '  Welda repo directory' "$WELDA_DIR_DEFAULT")"
  ruccess_dir="$(prompt_required '  Ruccess repo directory' "$RUCESS_DIR_DEFAULT")"

  write_account_config welda "$welda_name" "$welda_email" "$welda_user"
  write_account_config ruccess "$ruccess_name" "$ruccess_email" "$ruccess_user"
  ensure_global_include "$welda_dir" "$(account_config welda)"
  ensure_global_include "$ruccess_dir" "$(account_config ruccess)"
  install_ssh_config

  printf '\nNext:\n'
  printf '  git-account key welda\n'
  printf '  git-account key ruccess\n'
  printf '  pbcopy < ~/.ssh/id_ed25519_welda.pub\n'
  printf '  pbcopy < ~/.ssh/id_ed25519_ruccess.pub\n'
}

show_current() {
  local repo="${1:-.}"

  git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1 || die "not a git repo: $repo"

  printf 'repo:  %s\n' "$(git -C "$repo" rev-parse --show-toplevel)"
  printf 'name:  %s\n' "$(git -C "$repo" config --show-origin --get user.name 2>/dev/null || printf '(not set)')"
  printf 'email: %s\n' "$(git -C "$repo" config --show-origin --get user.email 2>/dev/null || printf '(not set)')"

  if git -C "$repo" remote get-url origin >/dev/null 2>&1; then
    printf 'origin: %s\n' "$(git -C "$repo" remote get-url origin)"
  fi
}

set_repo() {
  local account="${1:-}"
  local repo="${2:-.}"
  local config

  [ -n "$account" ] || die "missing account"
  config="$(account_config "$account")"
  [ -f "$config" ] || die "missing $config; run git-account init first"

  git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1 || die "not a git repo: $repo"
  git -C "$repo" config --local include.path "$config"
  log "Pinned $(git -C "$repo" rev-parse --show-toplevel) to $(account_name "$account")"
}

include_dir() {
  local account="${1:-}"
  local dir="${2:-}"
  local config

  [ -n "$account" ] || die "missing account"
  [ -n "$dir" ] || die "missing directory"

  config="$(account_config "$account")"
  [ -f "$config" ] || die "missing $config; run git-account init first"
  ensure_global_include "$dir" "$config"
}

create_key() {
  local account="${1:-}"
  local config
  local email
  local key

  [ -n "$account" ] || die "missing account"

  config="$(account_config "$account")"
  [ -f "$config" ] || die "missing $config; run git-account init first"

  email="$(git config --file "$config" --get user.email)"
  key="$(key_path "$account")"

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [ -f "$key" ]; then
    warn "$key already exists"
  else
    ssh-keygen -t ed25519 -C "$email" -f "$key"
  fi

  printf '\nPublic key:\n'
  printf '%s\n' "$(cat "$key.pub")"

  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy < "$key.pub"
    printf '\nCopied public key to clipboard.\n'
  fi
}

rewrite_remote() {
  local account="${1:-}"
  local remote="${2:-origin}"
  local repo="${3:-.}"
  local alias
  local url
  local new_url
  local rest

  [ -n "$account" ] || die "missing account"
  alias="$(host_alias "$account")"

  git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1 || die "not a git repo: $repo"
  url="$(git -C "$repo" remote get-url "$remote")"

  case "$url" in
    git@github.com:*)
      new_url="git@$alias:${url#git@github.com:}"
      ;;
    git@github.com-welda:*|git@github.com-ruccess:*|git@github.com-work:*|git@github.com-personal:*)
      rest="${url#git@github.com-welda:}"
      rest="${rest#git@github.com-ruccess:}"
      rest="${rest#git@github.com-work:}"
      rest="${rest#git@github.com-personal:}"
      new_url="git@$alias:$rest"
      ;;
    https://github.com/*)
      rest="${url#https://github.com/}"
      new_url="git@$alias:$rest"
      ;;
    *)
      die "remote does not look like a GitHub URL: $url"
      ;;
  esac

  git -C "$repo" remote set-url "$remote" "$new_url"
  log "Updated $remote to $new_url"
}

main() {
  local command="${1:-help}"

  case "$command" in
    init)
      shift
      init_accounts "$@"
      ;;
    current)
      shift
      show_current "${1:-.}"
      ;;
    set-repo)
      shift
      set_repo "$@"
      ;;
    include)
      shift
      include_dir "$@"
      ;;
    ssh-config)
      shift
      install_ssh_config "$@"
      ;;
    key)
      shift
      create_key "$@"
      ;;
    remote)
      shift
      rewrite_remote "$@"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
