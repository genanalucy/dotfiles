#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apply=0

case "${1:-}" in
  --apply) apply=1 ;;
  --dry-run|'') apply=0 ;;
  *) printf 'Usage: %s [--dry-run|--apply]\n' "$0" >&2; exit 2 ;;
esac

if ! command -v stow >/dev/null 2>&1; then
  printf 'stow is not installed. On macOS, run: brew install stow\n' >&2
  exit 1
fi

"$root/scripts/validate.sh"

cd "$root"
packages=(zsh tmux starship ghostty opencode ssh git nvim yazi)

if [ "$apply" -eq 0 ]; then
  printf 'Dry-run only. Use --apply after running scripts/backup-live-configs.sh and reviewing conflicts.\n'
  stow -n -v -t "$HOME" "${packages[@]}"
else
  latest_backup="$(ls -dt "$HOME"/.dotfiles-backup/* 2>/dev/null | head -n 1 || true)"
  if [ -z "$latest_backup" ]; then
    printf 'No backup found. Run scripts/backup-live-configs.sh first.\n' >&2
    exit 1
  fi
  stow -v -t "$HOME" "${packages[@]}"
fi
