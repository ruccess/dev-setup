# Managed by dev-setup.

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [ -n "${HOMEBREW_PREFIX:-}" ]; then
  [ -f "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/completion.zsh"
  [ -f "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ] && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
fi

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2 --git --group-directories-first'
fi

command -v bat >/dev/null 2>&1 && alias catp='bat --paging=never'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'
command -v lazydocker >/dev/null 2>&1 && alias lzd='lazydocker'
command -v k9s >/dev/null 2>&1 && alias k9='k9s'
command -v git-account >/dev/null 2>&1 && alias ga='git-account'

alias g='git'
alias reload!='source ~/.zshrc'

ws() {
  cd "$HOME/workspace" || return
}

mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

p() {
  local base="${1:-$HOME/workspace}"
  local dir

  if ! command -v fzf >/dev/null 2>&1; then
    printf 'fzf is not installed\n' >&2
    return 1
  fi

  if command -v fd >/dev/null 2>&1; then
    dir="$(fd . "$base" --type d --max-depth 2 --hidden --exclude .git | fzf --prompt='project> ' --preview='eza -la --git {} 2>/dev/null | head -80')"
  else
    dir="$(find "$base" -maxdepth 2 -type d -name .git -prune -o -type d -print | fzf --prompt='project> ')"
  fi

  [ -n "$dir" ] && cd "$dir" || return
}

logs() {
  if command -v lnav >/dev/null 2>&1; then
    lnav "$@"
  elif command -v tspin >/dev/null 2>&1; then
    tspin "$@"
  else
    less "$@"
  fi
}

path() {
  printf '%s\n' "${(s/:/)PATH}"
}
