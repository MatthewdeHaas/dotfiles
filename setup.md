# Terminal Environment Setup (WSL2 / Ubuntu)

## System Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget zsh stow tmux ripgrep fd-find fzf unzip
```


## Dotfiles

```bash
cd ~/.dotfiles
# Remove files that OMZ installer may have written
rm -f ~/.zshrc ~/.zshenv ~/.zprofile
stow $(ls -d */)
```

## Neovim

```bash
wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1
rm nvim-linux-x86_64.tar.gz
```

Verify: `nvim --version`

---

## eza (modern ls)

```bash
sudo apt install -y gpg
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
  | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update && sudo apt install -y eza
```

## Starship Prompt

```bash
curl -sS https://starship.rs/install.sh | sh -s -- --yes
```

## Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### Plugins

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

---

---

## 11. Set zsh as Default Shell

```bash
chsh -s $(which zsh)
```

Log out and back in for this to take effect.

---

## 12. First Launch

- **Neovim**: Run `nvim` — lazy.nvim will auto-install all plugins on first open.
- **Atuin**: Run `atuin login` to sync history.
- **gh**: Run `gh auth login` to authenticate.

---

## Kitty

Kitty runs on the **Windows side**, not inside WSL. Install it from:
https://sw.kovidgoyal.net/kitty/binary/

Your `kitty.conf` from the dotfiles repo won't be picked up automatically on Windows.
Copy it manually to `%APPDATA%\kitty\kitty.conf`, or symlink it if you're comfortable with Windows symlinks.

```Powershell
New-Item -ItemType Directory -Force "$env:APPDATA\kitty"
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\kitty\kitty.conf" `
  -Target "\\wsl$\Ubuntu\home\matthew\.dotfiles\kitty\.config\kitty\kitty.conf"
```


