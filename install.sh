#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BASHRC="$HOME/.bashrc"

# --- Helpers ---

ask() {
    local prompt="$1"
    while true;
    do
        read -rp "$prompt [y/N]: " ans
        case "$ans" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) return 1 ;;
        esac
    done
}

add_to_bashrc() {
    local marker="$1"
    local content="$2"
    if ! grep -q "$marker" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# $marker" >> "$BASHRC"
        echo "$content" >> "$BASHRC"
    fi
}

cmd_exists() {
    command -v "$1" &>/dev/null
}

ensure_bashrc() {
    [ -f "$BASHRC" ] || touch "$BASHRC"
}

# --- Init ---

ensure_bashrc

# Ensure ~/.local/bin is in PATH and .bashrc
export PATH="$HOME/.local/bin:$PATH"
add_to_bashrc "dotfiles-local-bin" 'export PATH="$HOME/.local/bin:$PATH"'

echo "=== Yorafa Dotfiles Installer ==="
echo ""

# 1. Zoxide
if ask "Install zoxide (fast directory jumping)?"; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    add_to_bashrc "zoxide" 'eval "$(zoxide init bash)"'
    echo "zoxide installed."
fi

# 2. ble.sh
if ask "Install ble.sh (bash line editor with syntax highlighting)?"; then
    echo "Installing ble.sh..."
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
    make -C /tmp/ble.sh install PREFIX="$HOME/.local"
    rm -rf /tmp/ble.sh
    add_to_bashrc "ble.sh" 'source -- ~/.local/share/blesh/ble.sh'
    echo "ble.sh installed."
fi

# 3. Starship
if ask "Install starship (cross-shell prompt)?"; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
    mkdir -p "$HOME/.config"
    cp "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
    add_to_bashrc "starship" 'eval "$(starship init bash)"'
    echo "starship installed."
fi

# 4. NVM
if ask "Install NVM (Node Version Manager)?"; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    echo "nvm installed (it adds its own lines to .bashrc)."
fi

# 5. Neovim (LazyVim)
if ask "Install Neovim + LazyVim config?"; then
    echo "Installing neovim..."
    if cmd_exists nvim; then
        echo "neovim already installed, skipping snap install."
    else
        sudo snap install nvim --classic
    fi
    echo "Copying nvim config..."
    cp -r "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    echo "neovim config installed. Run :Lazy on first launch to install plugins."

    if ask "  Install ripgrep (needed by neovim telescope)?"; then
        if cmd_exists rg; then
            echo "ripgrep already installed."
        else
            sudo apt install -y ripgrep
            echo "ripgrep installed."
        fi
    fi
fi

# 6. tmux
if ask "Install tmux?"; then
    echo "Installing tmux..."
    if cmd_exists tmux; then
        echo "tmux already installed."
    else
        sudo apt install -y tmux
    fi
    mkdir -p "$HOME/.config/tmux"
    cp "$DOTFILES_DIR"/tmux/* "$HOME/.config/tmux/"
    echo "tmux config installed."

    # TPM
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ -d "$TPM_DIR" ]; then
        echo "TPM already installed."
    else
        echo "Installing TPM (Tmux Plugin Manager)..."
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
        echo "TPM installed. Run prefix + I inside tmux to install plugins."
    fi
fi

# 7. Lazygit
if ask "Install lazygit (terminal Git UI)?"; then
  echo "Installing lazygit..."
  if cmd_exists lazygit; then
    echo "lazygit already installed."
  elif cmd_exists go; then
    go install github.com/jesseduffield/lazygit@latest
    echo "lazygit installed via go."
  else
    echo "Go not found, skipping lazygit. Install Go first, then run: go install github.com/jesseduffield/lazygit@latest"
  fi
fi

# 8. UV
if ask "Install uv (Python manager)?"; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installed (it adds its own lines to .bashrc)."
fi

echo ""
echo "=== Done! Restart your shell or run: source ~/.bashrc ==="
