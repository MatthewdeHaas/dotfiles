#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_REPO="https://github.com/MatthewdeHaas/dotfiles"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()    { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success() { echo -e "\033[1;32m[OK]\033[0m $1"; }
warning() { echo -e "\033[1;33m[WARN]\033[0m $1"; }

command_exists() { command -v "$1" &>/dev/null; }

# -----------------------------------------------------------------------------
# System packages
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
# fd-find installs as 'fdfind' on Ubuntu, alias to fd
if command_exists fdfind && ! command_exists fd; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

success "System packages installed."

# -----------------------------------------------------------------------------
# Neovim (latest stable via GitHub release)
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
# eza (modern ls)
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
#  Starship prompt
# -----------------------------------------------------------------------------
if ! command_exists starship; then
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
  success "starship installed."
else
  warning "starship already installed, skipping."
fi


# -----------------------------------------------------------------------------
# Oh My Zsh
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
#  stow dotfiles
# -----------------------------------------------------------------------------

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
# Set zsh as default shell
# -----------------------------------------------------------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
  info "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  success "Default shell set to zsh. Takes effect on next login."
else
  warning "zsh is already the default shell."
fi
