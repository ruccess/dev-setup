#!/usr/bin/env bash
set -euo pipefail

commands=(
  brew
  git
  git-account
  gh
  fzf
  zoxide
  atuin
  starship
  mise
  direnv
  eza
  bat
  fd
  rg
  jq
  yq
  lnav
  tspin
  btop
  lazygit
  lazydocker
  k9s
  yazi
  dust
  duf
  hyperfine
  just
  gum
  delta
  tmux
  xh
)

missing=0

printf 'dev-setup doctor\n\n'

for cmd in "${commands[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'ok      %-12s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'missing %-12s\n' "$cmd"
    missing=1
  fi
done

printf '\n'

if [ -d /Applications/Ghostty.app ]; then
  printf 'ok      %-12s %s\n' "Ghostty" "/Applications/Ghostty.app"
else
  printf 'missing %-12s\n' "Ghostty"
  missing=1
fi

if [ -d /Applications/Raycast.app ]; then
  printf 'ok      %-12s %s\n' "Raycast" "/Applications/Raycast.app"
else
  printf 'missing %-12s\n' "Raycast"
  missing=1
fi

printf '\nGit account configs\n\n'

account_dir="$HOME/.config/dev-setup/git/accounts"

if [ -d "$account_dir" ] && find "$account_dir" -maxdepth 1 -type f -name '*.gitconfig' -print -quit | grep -q .; then
  find "$account_dir" -maxdepth 1 -type f -name '*.gitconfig' -print | sort | while IFS= read -r config; do
    account="$(basename "$config" .gitconfig)"
    email="$(git config --file "$config" --get user.email 2>/dev/null || true)"
    directory="$(git config --file "$config" --get dev-setup.directory 2>/dev/null || true)"
    printf 'ok      %-12s %s\n' "$account" "${email:-$config}"
    if [ -n "$directory" ]; then
      printf '        %-12s %s\n' "" "$directory"
    fi
  done
else
  printf 'todo    %-12s run: git-account init\n' "accounts"
fi

exit "$missing"
