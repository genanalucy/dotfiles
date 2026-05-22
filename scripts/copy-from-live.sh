#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

copy_file() {
  local src="$1" dst="$2"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    cp -p "$src" "$dst"
    printf 'Copied %s -> %s\n' "$src" "$dst"
  fi
}

copy_dir_contents() {
  local src="$1" dst="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dst"
    rsync -a --delete \
      --exclude '.git' \
      --exclude '.DS_Store' \
      --exclude 'node_modules' \
      --exclude '.cache' \
      --exclude '.local' \
      --exclude 'sessions' \
      --exclude 'state' \
      --exclude '*.local' \
      "$src/" "$dst/"
    printf 'Copied %s/ -> %s/\n' "$src" "$dst"
  fi
}

copy_file "$HOME/.zshrc" "$root/zsh/.zshrc"
copy_file "$HOME/.zprofile" "$root/zsh/.zprofile"
copy_file "$HOME/.tmux.conf" "$root/tmux/.tmux.conf"
copy_file "$HOME/.config/starship.toml" "$root/starship/.config/starship.toml"
copy_dir_contents "$HOME/.config/ghostty" "$root/ghostty/.config/ghostty"
copy_dir_contents "$HOME/.config/opencode" "$root/opencode/.config/opencode"
copy_file "$HOME/.ssh/config" "$root/ssh/.ssh/config"
copy_file "$HOME/.gitconfig" "$root/git/.gitconfig"
copy_dir_contents "$HOME/.config/nvim" "$root/nvim/.config/nvim"
copy_dir_contents "$HOME/.config/yazi" "$root/yazi/.config/yazi"

"$root/scripts/validate.sh"
