#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

patterns=(
  'BEGIN OPENSSH PRIVATE KEY'
  'BEGIN RSA PRIVATE KEY'
  'BEGIN EC PRIVATE KEY'
  'github_pat_'
  'ghp_[A-Za-z0-9_]+'
  'sk-[A-Za-z0-9]+'
  'OPENAI_API_KEY'
  'ANTHROPIC_API_KEY'
  'api[_-]?key[[:space:]]*[:=]'
  'token[[:space:]]*[:=]'
  'secret[[:space:]]*[:=]'
  'password[[:space:]]*[:=]'
  'private_key'
)

status=0
for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!.git/**' --glob '!scripts/scan-secrets.sh' -e "$pattern" "$root" >/tmp/dotfiles-secret-scan.$$ 2>/dev/null; then
    printf 'Suspicious pattern found: %s\n' "$pattern" >&2
    cat /tmp/dotfiles-secret-scan.$$ >&2
    status=1
  fi
done
rm -f /tmp/dotfiles-secret-scan.$$

if [ "$status" -ne 0 ]; then
  printf '\nSecret scan failed. Review the matches before committing.\n' >&2
  exit "$status"
fi

printf 'Secret scan passed.\n'
