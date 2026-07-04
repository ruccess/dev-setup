#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_DIR="${DEV_SETUP_GIT_ACCOUNT_DIR:-$HOME/.config/dev-setup/git/accounts}"
SSH_CONFIG="${DEV_SETUP_SSH_CONFIG:-$HOME/.ssh/config}"
WORKSPACE_ROOT_DEFAULT="${DEV_SETUP_WORKSPACE_ROOT:-$HOME/workspace}"
ACCOUNT_DEFAULTS="${DEV_SETUP_ACCOUNT_DEFAULTS:-personal,work}"

SSH_BEGIN="# >>> dev-setup git accounts >>>"
SSH_END="# <<< dev-setup git accounts <<<"

usage() {
  cat <<'USAGE'
Usage: git-account <command> [args]

Commands:
  init                         Interactive account and workspace setup
  list                         List configured Git accounts
  current [repo]               Show the Git identity active for a repo
  set-repo <account> [repo]    Pin one repo to an account with local include.path
  include <account> <dir>      Add a global includeIf rule for a directory
  ssh-config [account...]      Install managed GitHub SSH host aliases
  key <account>                Create an ed25519 SSH key for an account
  remote <account> [remote] [repo]
                               Rewrite a GitHub remote to use the account SSH alias
  help                         Show this help

Examples:
  git-account init
  git-account list
  git-account current
  git-account set-repo ruccess ~/workspace/ruccess/dev-setup
  git-account remote welda origin ~/workspace/welda/api

SSH remote format:
  git@github.com-<account>:owner/repo.git
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

normalize_account() {
  local raw="${1:-}"
  local account

  account="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

  if [[ ! "$account" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
    die "invalid account id: $raw (use lowercase letters, numbers, dot, dash, or underscore)"
  fi

  printf '%s\n' "$account"
}

account_config() {
  local account
  account="$(normalize_account "${1:-}")"
  printf '%s/%s.gitconfig\n' "$ACCOUNT_DIR" "$account"
}

host_alias() {
  local account
  account="$(normalize_account "${1:-}")"
  printf 'github.com-%s\n' "$account"
}

key_path() {
  local account
  account="$(normalize_account "${1:-}")"
  printf '%s/.ssh/id_ed25519_%s\n' "$HOME" "$account"
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

prompt_yes_no() {
  local label="$1"
  local default="${2:-N}"
  local value
  local suffix

  case "$default" in
    Y|y) suffix="Y/n" ;;
    *) suffix="y/N" ;;
  esac

  read -r -p "$label [$suffix]: " value
  value="${value:-$default}"

  case "$value" in
    Y|y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

default_account_at() {
  local index="$1"
  local item
  local i=1

  IFS=',' read -r -a items <<< "$ACCOUNT_DEFAULTS"
  for item in "${items[@]}"; do
    if [ "$i" -eq "$index" ]; then
      printf '%s\n' "$item"
      return
    fi
    i=$((i + 1))
  done

  printf 'account%s\n' "$index"
}

configured_accounts() {
  if [ ! -d "$ACCOUNT_DIR" ]; then
    return
  fi

  find "$ACCOUNT_DIR" -maxdepth 1 -type f -name '*.gitconfig' -print 2>/dev/null |
    while IFS= read -r file; do
      basename "$file" .gitconfig
    done |
    sort
}

write_account_config() {
  local account="$1"
  local name="$2"
  local email="$3"
  local github_user="$4"
  local directory="$5"
  local config
  local host
  local key

  account="$(normalize_account "$account")"
  config="$(account_config "$account")"
  host="$(host_alias "$account")"
  key="$(key_path "$account")"

  mkdir -p "$ACCOUNT_DIR"

  cat > "$config" <<EOF
[user]
	name = $name
	email = $email

[github]
	user = $github_user

[dev-setup]
	directory = $directory
	githubHost = $host
	identityFile = $key
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
  local accounts=("$@")
  local account
  local dir
  local tmp

  if [ "${#accounts[@]}" -eq 0 ]; then
    while IFS= read -r account; do
      accounts+=("$account")
    done < <(configured_accounts)
  fi

  if [ "${#accounts[@]}" -eq 0 ]; then
    die "no accounts configured; run git-account init first"
  fi

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

  printf '\n%s\n' "$SSH_BEGIN" >> "$tmp"
  for account in "${accounts[@]}"; do
    account="$(normalize_account "$account")"
    {
      printf 'Host %s\n' "$(host_alias "$account")"
      printf '  HostName github.com\n'
      printf '  User git\n'
      printf '  IdentityFile %s\n' "$(key_path "$account")"
      printf '  IdentitiesOnly yes\n'
      printf '\n'
    } >> "$tmp"
  done
  printf '%s\n' "$SSH_END" >> "$tmp"

  mv "$tmp" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
  log "Installed SSH host aliases in $SSH_CONFIG"
}

init_accounts() {
  local default_name
  local default_email
  local workspace_root
  local count
  local account
  local name
  local email
  local github_user
  local repo_dir
  local i
  local accounts=()

  default_name="$(git config --global --get user.name 2>/dev/null || true)"
  default_email="$(git config --global --get user.email 2>/dev/null || true)"

  workspace_root="$(prompt_required 'Workspace root' "$WORKSPACE_ROOT_DEFAULT")"
  count="$(prompt_required 'Number of Git accounts' "${DEV_SETUP_ACCOUNT_COUNT:-2}")"

  if [[ ! "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ]; then
    die "Number of Git accounts must be a positive integer"
  fi

  printf '\nAccount IDs become folder names, SSH aliases, and config filenames.\n'
  printf 'Examples: ruccess, welda, personal, work\n\n'

  for ((i = 1; i <= count; i++)); do
    printf 'Account %s\n' "$i"
    account="$(prompt_required '  Account id' "$(default_account_at "$i")")"
    account="$(normalize_account "$account")"
    name="$(prompt_required '  Git name' "$default_name")"
    email="$(prompt_required '  Git email' "$default_email")"
    github_user="$(prompt '  GitHub username or org login' "$account")"
    repo_dir="$(prompt_required '  Repo directory' "$workspace_root/$account")"
    printf '\n'

    write_account_config "$account" "$name" "$email" "$github_user" "$repo_dir"
    ensure_global_include "$repo_dir" "$(account_config "$account")"
    accounts+=("$account")
  done

  install_ssh_config "${accounts[@]}"

  printf '\nNext:\n'
  for account in "${accounts[@]}"; do
    printf '  git-account key %s\n' "$account"
  done
  printf '\nAfter adding public keys to GitHub, use remotes like:\n'
  printf '  git@github.com-<account>:owner/repo.git\n'
}

list_accounts() {
  local account
  local accounts=()
  local config
  local email
  local directory
  local host

  while IFS= read -r account; do
    accounts+=("$account")
  done < <(configured_accounts)

  if [ "${#accounts[@]}" -eq 0 ]; then
    warn "No accounts configured. Run: git-account init"
    return 1
  fi

  for account in "${accounts[@]}"; do
    config="$(account_config "$account")"
    email="$(git config --file "$config" --get user.email 2>/dev/null || true)"
    directory="$(git config --file "$config" --get dev-setup.directory 2>/dev/null || true)"
    host="$(host_alias "$account")"
    printf '%-16s %-32s %s\n' "$account" "${email:-"(no email)"}" "$host"
    if [ -n "$directory" ]; then
      printf '  dir: %s\n' "$directory"
    fi
  done
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
  account="$(normalize_account "$account")"
  config="$(account_config "$account")"
  [ -f "$config" ] || die "missing $config; run git-account init first"

  git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1 || die "not a git repo: $repo"
  git -C "$repo" config --local include.path "$config"
  log "Pinned $(git -C "$repo" rev-parse --show-toplevel) to $account"
}

include_dir() {
  local account="${1:-}"
  local dir="${2:-}"
  local config

  [ -n "$account" ] || die "missing account"
  [ -n "$dir" ] || die "missing directory"

  account="$(normalize_account "$account")"
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
  account="$(normalize_account "$account")"

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

  install_ssh_config

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
  account="$(normalize_account "$account")"
  alias="$(host_alias "$account")"

  git -C "$repo" rev-parse --show-toplevel >/dev/null 2>&1 || die "not a git repo: $repo"
  url="$(git -C "$repo" remote get-url "$remote")"

  case "$url" in
    git@github.com:*)
      rest="${url#git@github.com:}"
      ;;
    git@github.com-*:*)
      rest="${url#git@github.com-}"
      rest="${rest#*:}"
      ;;
    https://github.com/*)
      rest="${url#https://github.com/}"
      ;;
    *)
      die "remote does not look like a GitHub URL: $url"
      ;;
  esac

  new_url="git@$alias:$rest"
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
    list)
      shift
      list_accounts "$@"
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
