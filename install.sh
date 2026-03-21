#!/usr/bin/env bash

set -e

echo "🚀 Zsh + Powerlevel10k PRO setup starting..."

OS="$(uname)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# -------------------------
# Utils
# -------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

backup_file() {
  FILE=$1
  if [ -f "$FILE" ]; then
    BACKUP="$FILE.backup.$(date +%s)"
    echo "📦 Backing up $FILE → $BACKUP"
    cp "$FILE" "$BACKUP"
  fi
}

clone_if_missing() {
  REPO=$1
  DEST=$2
  if [ ! -d "$DEST" ]; then
    git clone --depth=1 "$REPO" "$DEST"
  else
    echo "✔ Already exists: $DEST"
  fi
}

# -------------------------
# Install dependencies
# -------------------------
install_deps() {
  if [[ "$OS" == "Darwin" ]]; then
    echo "🍎 macOS detected"

    if ! command_exists brew; then
      echo "📦 Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew install zsh git curl wget unzip fontconfig

  else
    echo "🐧 Linux detected"

    if command_exists apt; then
      sudo apt update
      sudo apt install -y zsh git curl wget unzip fontconfig
    elif command_exists pacman; then
      sudo pacman -S --noconfirm zsh git curl wget unzip fontconfig
    elif command_exists dnf; then
      sudo dnf install -y zsh git curl wget unzip fontconfig
    fi
  fi
}

# -------------------------
# Nerd Font install
# -------------------------
install_font() {
  echo "🔤 Installing Meslo Nerd Font..."

  FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  if ! ls "$FONT_DIR" | grep -qi "Meslo"; then
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -O "$FONT_DIR/MesloLGS NF Regular.ttf"
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -O "$FONT_DIR/MesloLGS NF Bold.ttf"
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf -O "$FONT_DIR/MesloLGS NF Italic.ttf"
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -O "$FONT_DIR/MesloLGS NF Bold Italic.ttf"

    if command_exists fc-cache; then
      fc-cache -fv
    fi
  else
    echo "✔ Font already installed"
  fi
}

# -------------------------
# Oh My Zsh
# -------------------------
install_ohmyzsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "⚡ Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "✔ Oh My Zsh already installed"
  fi
}

# -------------------------
# Powerlevel10k
# -------------------------
install_p10k() {
  echo "🎨 Installing Powerlevel10k..."
  clone_if_missing https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
}

# -------------------------
# Plugins
# -------------------------
install_plugins() {
  echo "🔌 Installing plugins..."

  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
}

# -------------------------
# Apply config
# -------------------------
setup_zshrc() {
  backup_file "$HOME/.zshrc"

  echo "⚙️ Writing .zshrc..."

  cat > "$HOME/.zshrc" <<'EOF'
# Instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"

# Auto-load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
}

# -------------------------
# Preconfigured p10k
# -------------------------

setup_p10k_config() {
  echo "⚡ Applying your custom Powerlevel10k config..."

  # Backup if exists
  if [ -f "$HOME/.p10k.zsh" ]; then
    cp "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup.$(date +%s)"
  fi

  # Download YOUR config from GitHub
  curl -fsSL https://raw.githubusercontent.com/AbhiramaMekala/TerminalSetup/main/p10k.zsh \
    -o "$HOME/.p10k.zsh"
}

# -------------------------
# Default shell
# -------------------------
set_shell() {
  if [[ "$SHELL" != *"zsh" ]]; then
    echo "🔁 Setting zsh as default shell..."
    chsh -s "$(which zsh)"
  else
    echo "✔ Zsh already default"
  fi
}

# -------------------------
# Run all
# -------------------------
install_deps
install_font
install_ohmyzsh
install_p10k
install_plugins
setup_zshrc
setup_p10k_config
set_shell

echo ""
echo "✅ DONE!"
echo "👉 Restart terminal"
echo "👉 Set terminal font to: MesloLGS NF"

zsh
source ~/.zshrc
