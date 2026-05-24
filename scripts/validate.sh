#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

required_dirs=(zsh tmux starship ghostty opencode ssh git nvim yazi scripts)
for dir in "${required_dirs[@]}"; do
  test -d "$root/$dir" || { printf 'Missing directory: %s\n' "$dir" >&2; exit 1; }
done

"$root/scripts/scan-secrets.sh"

if command -v zsh >/dev/null 2>&1 && [ -f "$root/zsh/.zshrc" ]; then
  zsh -n "$root/zsh/.zshrc"
fi

if command -v tmux >/dev/null 2>&1 && [ -f "$root/tmux/.tmux.conf" ]; then
  tmux -f "$root/tmux/.tmux.conf" start-server >/dev/null 2>&1 || true
fi

if command -v stow >/dev/null 2>&1; then
  stow -n -v -t "$HOME" zsh tmux starship ghostty opencode ssh git nvim yazi >/dev/null
  printf 'Stow dry-run passed.\n'
else
  printf 'Skipping Stow dry-run: stow is not installed.\n'
fi

printf 'Validation complete.\n'
