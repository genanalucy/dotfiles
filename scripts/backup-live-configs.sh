#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/.dotfiles-backup/$timestamp"
mkdir -p "$backup_dir"

backup_path() {
  local src="$1"
  if [ -e "$src" ] || [ -L "$src" ]; then
    local rel="${src#$HOME/}"
    mkdir -p "$backup_dir/$(dirname "$rel")"
    cp -a "$src" "$backup_dir/$rel"
    printf 'Backed up %s -> %s\n' "$src" "$backup_dir/$rel"
  fi
}

backup_path "$HOME/.zshrc"
backup_path "$HOME/.zprofile"
backup_path "$HOME/.tmux.conf"
backup_path "$HOME/.config/starship.toml"
backup_path "$HOME/.config/ghostty"
backup_path "$HOME/.config/opencode"
backup_path "$HOME/.ssh/config"
backup_path "$HOME/.gitconfig"
backup_path "$HOME/.config/nvim"
backup_path "$HOME/.config/yazi"

printf 'Backup created at %s\n' "$backup_dir"
