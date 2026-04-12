#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO="https://github.com/MatthewdeHaas/dotfiles"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

command_exists() { command -v "$1" &>/dev/null; }

# -----------------------------------------------------------------------------
# 1. System packages
# -----------------------------------------------------------------------------
info "Updating apt and installing system packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git \
  curl \
  wget \
  zsh \
  stow \
  tmux \
  htop \
  fd-find \
  fzf \
  unzip \
  build-essential \
  python3 \
  python3-pip \

# fd-find installs as 'fdfind' on Ubuntu, alias to fd
if command_exists fdfind && ! command_exists fd; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

success "System packages installed."

# -----------------------------------------------------------------------------
# 2. Neovim (latest stable via GitHub release)
# -----------------------------------------------------------------------------
if ! command_exists nvim; then
  info "Installing Neovim..."
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  wget -q "$NVIM_URL" -O /tmp/nvim.tar.gz
  sudo tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1
  rm /tmp/nvim.tar.gz
  success "Neovim installed ($(nvim --version | head -1))."
else
  warning "Neovim already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 3. eza (modern ls)
# -----------------------------------------------------------------------------
if ! command_exists eza; then
  info "Installing eza..."
  sudo apt install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update && sudo apt install -y eza
  success "eza installed."
else
  warning "eza already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 4. Zoxide
# -----------------------------------------------------------------------------
if ! command_exists zoxide; then
  info "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  success "zoxide installed."
else
  warning "zoxide already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 5. Atuin (shell history)
# -----------------------------------------------------------------------------
if ! command_exists atuin; then
  info "Installing atuin..."
  bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
  success "atuin installed."
else
  warning "atuin already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 6. Starship prompt
# -----------------------------------------------------------------------------
if ! command_exists starship; then
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "starship installed."
else
  warning "starship already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 7. uv (Python manager, replaces pip/pyenv)
# -----------------------------------------------------------------------------
if ! command_exists uv; then
  info "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  success "uv installed."
else
  warning "uv already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 8. tspin (log viewer, 'tlog' alias)
# -----------------------------------------------------------------------------
if ! command_exists tspin; then
  info "Installing tspin..."
  # tspin is a Rust binary — install via cargo if available, else download release
  if command_exists cargo; then
    cargo install tailspin
  else
    TSPIN_URL="https://github.com/bensadeh/tailspin/releases/latest/download/tspin-x86_64-unknown-linux-gnu.tar.gz"
    wget -q "$TSPIN_URL" -O /tmp/tspin.tar.gz
    tar -xzf /tmp/tspin.tar.gz -C "$HOME/.local/bin"
    rm /tmp/tspin.tar.gz
  fi
  success "tspin installed."
else
  warning "tspin already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 9. GitHub CLI (gh)
# -----------------------------------------------------------------------------
if ! command_exists gh; then
  info "Installing GitHub CLI..."
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list
  sudo apt update && sudo apt install -y gh
  success "GitHub CLI installed."
else
  warning "gh already installed, skipping."
fi

# -----------------------------------------------------------------------------
# 10. Oh My Zsh
# -----------------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  success "Oh My Zsh installed."
else
  warning "Oh My Zsh already installed, skipping."
fi

# OMZ custom plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  info "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  info "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

success "OMZ plugins installed."

# -----------------------------------------------------------------------------
# 11. Clone dotfiles and stow
# -----------------------------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
  info "Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  warning "Dotfiles directory already exists, pulling latest..."
  git -C "$DOTFILES_DIR" pull
fi

info "Stowing dotfiles..."
cd "$DOTFILES_DIR"

# Remove any existing configs that would conflict before stowing
# (OMZ installer writes a fresh .zshrc, so we need to remove it first)
[ -f "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -f "$HOME/.zshenv" ] && rm "$HOME/.zshenv"
[ -f "$HOME/.zprofile" ] && rm "$HOME/.zprofile"

stow --simulate $(ls) && stow $(ls)
success "Dotfiles stowed."

# -----------------------------------------------------------------------------
# 12. Set zsh as default shell
# -----------------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  success "Default shell set to zsh. Takes effect on next login."
else
  warning "zsh is already the default shell."
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo -e "\033[1;32m============================================\033[0m"
echo -e "\033[1;32m  Bootstrap complete.\033[0m"
echo -e "\033[1;32m============================================\033[0m"
echo ""
echo "Next steps:"
echo "  1. Restart your shell (or open a new terminal)"
echo "  2. Open nvim — lazy.nvim will auto-install plugins on first launch"
echo "  3. Run 'atuin login' if you sync shell history across machines"
echo "  4. Run 'gh auth login' to authenticate the GitHub CLI"
echo ""
