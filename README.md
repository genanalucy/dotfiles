# dotFiles_Manager

这是当前 Mac 的个人 dotfiles 源仓库，目标是用 GNU Stow 快速迁移到新的 macOS 或 Linux 主机。

当前纳管范围：`zsh`、`tmux`、`starship`、`ghostty`、`opencode`、`ssh`、`git`、`nvim`、`yazi`。

## 安全原则

- 只复制配置，不默认替换当前正在使用的文件。
- `ssh` 只纳管 `~/.ssh/config`，不纳管私钥、`known_hosts`、`authorized_keys`。
- 不提交 API key、token、密码、`.env`、本机 local override、缓存或运行状态。
- 真实安装前先备份，再 dry-run，最后才 `--apply`。

## 从当前 Mac 同步配置

```sh
scripts/copy-from-live.sh
scripts/validate.sh
```

如果 secret scan 报警，先人工检查匹配内容，不要直接提交。

## 安装到本机或新机器

先安装 Stow：

```sh
brew install stow
```

Linux 上使用系统包管理器安装 `stow`，例如 `sudo apt install stow`。

先备份：

```sh
scripts/backup-live-configs.sh
```

再 dry-run：

```sh
scripts/install-stow.sh --dry-run
```

确认无冲突后再应用：

```sh
scripts/install-stow.sh --apply
```

## 回滚

如果需要撤销 Stow 链接：

```sh
stow -D -t "$HOME" zsh tmux starship ghostty opencode ssh git nvim yazi
```

然后从 `~/.dotfiles-backup/<timestamp>/` 恢复对应文件。

## 新 Linux 主机同步配置

### 1. 安装基础依赖

Debian / Ubuntu：

```sh
sudo apt update
sudo apt install -y git stow zsh tmux neovim
```

Arch Linux：

```sh
sudo pacman -S git stow zsh tmux neovim
```

Fedora：

```sh
sudo dnf install git stow zsh tmux neovim
```

如果要完整使用提示符和文件管理器，还需要安装 `starship` 和 `yazi`。不同发行版包名可能不同，按目标系统实际情况安装。

### 2. 克隆仓库

```sh
git clone https://github.com/genanalucy/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. 验证配置

```sh
scripts/validate.sh
```

如果这里提示 secret scan 或配置检查失败，先处理错误，不要继续安装。

### 4. 备份目标主机现有配置

```sh
scripts/backup-live-configs.sh
```

备份会放到：

```text
~/.dotfiles-backup/<timestamp>/
```

### 5. 先 dry-run

```sh
scripts/install-stow.sh --dry-run
```

如果提示冲突，说明目标机器已有真实配置文件，例如 `~/.zshrc`、`~/.tmux.conf`、`~/.config/nvim` 或 `~/.config/yazi`。确认已经备份后，把冲突项移走，再重新 dry-run。

### 6. 应用 Stow 链接

```sh
scripts/install-stow.sh --apply
```

### 7. 切换默认 shell

```sh
chsh -s "$(command -v zsh)"
```

重新登录 SSH 或重新打开终端后生效。

### 8. 后续同步更新

在主设备 Mac 修改并 push 后，Linux 主机执行：

```sh
cd ~/dotfiles
git pull
scripts/validate.sh
scripts/install-stow.sh --dry-run
scripts/install-stow.sh --apply
```

Ghostty 和 OpenCode 不存在时，不应阻塞基础 shell、tmux、git、nvim、yazi 配置迁移。
