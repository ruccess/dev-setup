#!/usr/bin/env bash
set -euo pipefail

missing=0
selected_brewfile="$HOME/.config/dev-setup/Brewfile.selected"

printf 'dev-setup doctor\n\n'

for cmd in brew git git-account nvim-profile dev-setup; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf 'ok      %-12s %s\n' "$cmd" "$(command -v "$cmd")"
  else
    printf 'missing %-12s\n' "$cmd"
    missing=1
  fi
done

printf '\n'

printf 'Selected Homebrew packages\n\n'

if [ -f "$selected_brewfile" ]; then
  package_count=0
  while IFS= read -r line; do
    case "$line" in
      brew\ \"*\")
        name="${line#brew \"}"
        name="${name%%\"*}"
        package_count=$((package_count + 1))
        if brew list --formula "$name" >/dev/null 2>&1; then
          printf 'ok      brew         %s\n' "$name"
        else
          printf 'missing brew         %s\n' "$name"
          missing=1
        fi
        ;;
      cask\ \"*\")
        name="${line#cask \"}"
        name="${name%%\"*}"
        package_count=$((package_count + 1))
        if brew list --cask "$name" >/dev/null 2>&1; then
          printf 'ok      cask         %s\n' "$name"
        else
          printf 'missing cask         %s\n' "$name"
          missing=1
        fi
        ;;
    esac
  done < "$selected_brewfile"

  if [ "$package_count" -eq 0 ]; then
    printf 'ok      %-12s no Homebrew tools selected\n' "brewfile"
  fi
else
  printf 'todo    %-12s run ./install.sh to create %s\n' "brewfile" "$selected_brewfile"
fi

printf '\nLinked configs\n\n'

zellij_layout="$HOME/.config/zellij/layouts/dev.kdl"

if [ -f "$zellij_layout" ]; then
  printf 'ok      %-12s %s\n' "zellij" "$zellij_layout"
else
  printf 'todo    %-12s run ./install.sh to link %s\n' "zellij" "$zellij_layout"
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
