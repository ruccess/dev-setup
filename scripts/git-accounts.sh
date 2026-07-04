#!/usr/bin/env bash
set -euo pipefail

ACCOUNT_DIR="${DEV_SETUP_GIT_ACCOUNT_DIR:-$HOME/.config/dev-setup/git/accounts}"
SSH_CONFIG="${DEV_SETUP_SSH_CONFIG:-$HOME/.ssh/config}"
WORK_DIR_DEFAULT="${DEV_SETUP_WORK_DIR:-$HOME/workspace/work}"
PERSONAL_DIR_DEFAULT="${DEV_SETUP_PERSONAL_DIR:-$HOME/workspace/personal}"

SSH_BEGIN="# >>> dev-setup git accounts >>>"
SSH_END="# <<< dev-setup git accounts <<<"

usage() {
  cat <<'USAGE'
Usage: git-account <command> [args]

Commands:
  init                         Create local work/personal configs and directory includes
  current [repo]               Show the Git identity active for a repo
  set-repo <work|personal> [repo]
                               Pin one repo to an account with local include.path
  include <work|personal> <dir>
                               Add a global includeIf rule for a directory
  ssh-config                   Install managed GitHub SSH host aliases
  key <work|personal>          Create an ed25519 SSH key for an account
  remote <work|personal> [remote] [repo]
                               Rewrite a GitHub remote to use the account SSH alias
  help                         Show this help

Examples:
  git-account init
  git-account current
  git-account set-repo work ~/workspace/wd-cron
  git-account remote personal origin ~/workspace/personal/dotfiles

SSH remotes:
  git@github.com-work:company/repo.git
  git@github.com-personal:username/repo.git
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
    work|company) printf '%s/work.gitconfig\n' "$ACCOUNT_DIR" ;;
    personal) printf '%s/personal.gitconfig\n' "$ACCOUNT_DIR" ;;
    *) die "unknown account: ${1:-} (use work or personal)" ;;
  esac
}

account_name() {
  case "${1:-}" in
    work|company) printf 'work\n' ;;
    personal) printf 'personal\n' ;;
    *) die "unknown account: ${1:-} (use work or personal)" ;;
  esac
}

host_alias() {
  case "$(account_name "$1")" in
    work) printf 'github.com-work\n' ;;
    personal) printf 'github.com-personal\n' ;;
  esac
}

key_path() {
  case "$(account_name "$1")" in
    work) printf '%s/.ssh/id_ed25519_work\n' "$HOME" ;;
    personal) printf '%s/.ssh/id_ed25519_personal\n' "$HOME" ;;
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
    printf 'Host github.com-work\n'
    printf '  HostName github.com\n'
    printf '  User git\n'
    printf '  IdentityFile ~/.ssh/id_ed25519_work\n'
    printf '  IdentitiesOnly yes\n'
    printf '\n'
    printf 'Host github.com-personal\n'
    printf '  HostName github.com\n'
    printf '  User git\n'
    printf '  IdentityFile ~/.ssh/id_ed25519_personal\n'
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
  local work_name
  local work_email
  local work_user
  local personal_name
  local personal_email
  local personal_user
  local work_dir
  local personal_dir

  default_name="$(git config --global --get user.name 2>/dev/null || true)"
  default_email="$(git config --global --get user.email 2>/dev/null || true)"

  printf 'Work account\n'
  work_name="$(prompt_required '  Git name' "$default_name")"
  work_email="$(prompt_required '  Git email' "$default_email")"
  work_user="$(prompt '  GitHub username/org login' '')"
  printf '\nPersonal account\n'
  personal_name="$(prompt_required '  Git name' "$default_name")"
  personal_email="$(prompt_required '  Git email' '')"
  personal_user="$(prompt '  GitHub username' '')"
  printf '\nDirectories\n'
  work_dir="$(prompt_required '  Work repo directory' "$WORK_DIR_DEFAULT")"
  personal_dir="$(prompt_required '  Personal repo directory' "$PERSONAL_DIR_DEFAULT")"

  write_account_config work "$work_name" "$work_email" "$work_user"
  write_account_config personal "$personal_name" "$personal_email" "$personal_user"
  ensure_global_include "$work_dir" "$(account_config work)"
  ensure_global_include "$personal_dir" "$(account_config personal)"
  install_ssh_config

  printf '\nNext:\n'
  printf '  git-account key work\n'
  printf '  git-account key personal\n'
  printf '  pbcopy < ~/.ssh/id_ed25519_work.pub\n'
  printf '  pbcopy < ~/.ssh/id_ed25519_personal.pub\n'
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
    git@github.com-work:*|git@github.com-personal:*)
      rest="${url#git@github.com-work:}"
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
