#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apply=0
install_optional=1
change_shell=0

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-linux.sh [--dry-run|--apply] [--no-optional] [--change-shell]

Installs Linux dependencies, backs up existing configs, moves conflicting files
into the backup directory, and applies GNU Stow symlinks.

Default is --dry-run. Use --apply to modify the system.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) apply=1 ;;
    --dry-run) apply=0 ;;
    --no-optional) install_optional=0 ;;
    --change-shell) change_shell=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

log() {
  printf '\n==> %s\n' "$1"
}

run() {
  if [ "$apply" -eq 1 ]; then
    "$@"
  else
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  fi
}

need_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

detect_pm() {
  if command -v apt-get >/dev/null 2>&1; then
    printf 'apt'
  elif command -v dnf >/dev/null 2>&1; then
    printf 'dnf'
  elif command -v pacman >/dev/null 2>&1; then
    printf 'pacman'
  else
    printf 'unknown'
  fi
}

install_base_packages() {
  local pm="$1"
  case "$pm" in
    apt)
      run need_sudo apt-get update
      run need_sudo apt-get install -y git stow zsh tmux neovim curl ca-certificates build-essential fzf ripgrep fd-find
      ;;
    dnf)
      run need_sudo dnf install -y git stow zsh tmux neovim curl ca-certificates gcc gcc-c++ make fzf ripgrep fd-find
      ;;
    pacman)
      run need_sudo pacman -Syu --needed --noconfirm git stow zsh tmux neovim curl base-devel fzf ripgrep fd
      ;;
    *)
      printf 'Unsupported package manager. Install at least: git stow zsh tmux neovim curl\n' >&2
      return 1
      ;;
  esac
}

install_starship() {
  if command -v starship >/dev/null 2>&1; then
    printf 'starship already installed: %s\n' "$(command -v starship)"
    return 0
  fi

  if [ "$install_optional" -eq 0 ]; then
    printf 'Skipping optional starship install.\n'
    return 0
  fi

  if [ "$apply" -eq 1 ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  else
    printf 'DRY-RUN: curl -sS https://starship.rs/install.sh | sh -s -- -y\n'
  fi
}

install_yazi_if_available() {
  if command -v yazi >/dev/null 2>&1; then
    printf 'yazi already installed: %s\n' "$(command -v yazi)"
    return 0
  fi

  if [ "$install_optional" -eq 0 ]; then
    printf 'Skipping optional yazi install.\n'
    return 0
  fi

  case "$pm" in
    apt)
      if command -v apt-cache >/dev/null 2>&1 && apt-cache show yazi >/dev/null 2>&1; then
        run need_sudo apt-get install -y yazi
      else
        printf 'Skipping yazi: not available from this apt repository.\n'
      fi
      ;;
    dnf)
      run need_sudo dnf install -y yazi || printf 'Skipping yazi: dnf install failed.\n'
      ;;
    pacman)
      run need_sudo pacman -S --needed --noconfirm yazi
      ;;
  esac
}

install_oh_my_zsh() {
  if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    printf 'Oh My Zsh already installed.\n'
    return 0
  fi

  if [ "$install_optional" -eq 0 ]; then
    printf 'Skipping optional Oh My Zsh install.\n'
    return 0
  fi

  if [ "$apply" -eq 1 ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    printf 'DRY-RUN: install Oh My Zsh with RUNZSH=no CHSH=no KEEP_ZSHRC=yes\n'
  fi
}

backup_dir=''
create_backup() {
  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$HOME/.dotfiles-backup/$timestamp"

  run mkdir -p "$backup_dir"
  if [ "$apply" -eq 1 ]; then
    "$root/scripts/backup-live-configs.sh"
    backup_dir="$(ls -dt "$HOME"/.dotfiles-backup/* 2>/dev/null | head -n 1)"
  fi
  printf 'Backup directory: %s\n' "$backup_dir"
}

move_conflict() {
  local target="$1"
  local rel

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi

  if [ -L "$target" ]; then
    local resolved
    resolved="$(readlink "$target")"
    case "$resolved" in
      *dotfiles*|*dotFiles_Manager*)
        printf 'Already managed: %s -> %s\n' "$target" "$resolved"
        return 0
        ;;
    esac
  fi

  rel="${target#$HOME/}"
  run mkdir -p "$backup_dir/moved-before-stow/$(dirname "$rel")"
  run mv "$target" "$backup_dir/moved-before-stow/$rel"
}

move_conflicts() {
  move_conflict "$HOME/.zshrc"
  move_conflict "$HOME/.zprofile"
  move_conflict "$HOME/.tmux.conf"
  move_conflict "$HOME/.config/starship.toml"
  move_conflict "$HOME/.config/ghostty"
  move_conflict "$HOME/.config/opencode"
  move_conflict "$HOME/.ssh/config"
  move_conflict "$HOME/.gitconfig"
  move_conflict "$HOME/.config/nvim"
  move_conflict "$HOME/.config/yazi"
}

apply_stow() {
  if [ "$apply" -eq 1 ]; then
    "$root/scripts/install-stow.sh" --apply
  else
    "$root/scripts/install-stow.sh" --dry-run || true
  fi
}

change_default_shell() {
  if [ "$change_shell" -eq 0 ]; then
    printf 'Skipping default shell change. Use --change-shell to run chsh.\n'
    return 0
  fi

  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    printf 'zsh is not installed; cannot change shell.\n' >&2
    return 1
  fi

  run chsh -s "$zsh_path"
}

log 'Checking platform'
if [ "$(uname -s)" != 'Linux' ]; then
  printf 'This script is intended for Linux hosts.\n' >&2
  exit 1
fi

pm="$(detect_pm)"
printf 'Package manager: %s\n' "$pm"

log 'Installing base packages'
install_base_packages "$pm"

log 'Installing optional prompt tools'
install_starship
install_oh_my_zsh
install_yazi_if_available

log 'Running preflight checks'
if [ "$apply" -eq 1 ]; then
  "$root/scripts/scan-secrets.sh"
  if command -v zsh >/dev/null 2>&1; then
    zsh -n "$root/zsh/.zshrc" "$root/zsh/.zprofile"
  fi
else
  printf 'DRY-RUN: %s/scripts/scan-secrets.sh\n' "$root"
  printf 'DRY-RUN: zsh -n %s/zsh/.zshrc %s/zsh/.zprofile\n' "$root" "$root"
fi

log 'Backing up and moving conflicts'
create_backup
move_conflicts

log 'Applying Stow'
apply_stow

log 'Changing default shell'
change_default_shell

log 'Final checks'
if [ "$apply" -eq 1 ]; then
  "$root/scripts/validate.sh"
  printf 'zshrc: '; ls -la "$HOME/.zshrc" || true
  printf 'tmux: '; ls -la "$HOME/.tmux.conf" || true
  printf 'nvim: '; ls -la "$HOME/.config/nvim" || true
  printf 'starship: '; ls -la "$HOME/.config/starship.toml" || true
else
  printf 'Dry-run complete. Re-run with --apply to install and replace configs.\n'
fi
