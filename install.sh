#!/bin/bash
set -e

DOTFILES_DIR="$PWD"

# Symlink dotfiles
for file in .zshrc; do
  if [ -f "$DOTFILES_DIR/$file" ]; then
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "Symlinked $file"
  fi
done

# Symlink .zshrc from config/zsh if it exists
if [ -f "$DOTFILES_DIR/config/zsh/.zshrc" ]; then
  ln -sf "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
  echo "Symlinked .zshrc from config/zsh"
fi

# Copy .zsh directory
if [ -d "$DOTFILES_DIR/config/zsh/.zsh" ]; then
  rsync -a --exclude='.git' "$DOTFILES_DIR/config/zsh/.zsh/" "$HOME/.zsh/"
  echo "Copied .zsh directory"
fi

# Neovim
if [ -d "$DOTFILES_DIR/config/editor/nvim" ]; then
  mkdir -p "$HOME/.config/nvim"
  rsync -a --exclude='.git' "$DOTFILES_DIR/config/editor/nvim/" "$HOME/.config/nvim/"
  echo "Copied config/editor/nvim to .config/nvim"
fi

# Cursor
if [ -d "$DOTFILES_DIR/config/editor/Cursor" ]; then
  mkdir -p "$HOME/.config/Cursor"
  rsync -a --exclude='.git' "$DOTFILES_DIR/config/editor/Cursor/" "$HOME/.config/Cursor/"
  echo "Copied config/editor/Cursor to .config/Cursor"
fi

# Ghostty
if [ -d "$DOTFILES_DIR/config/terminal/ghostty" ]; then
  mkdir -p "$HOME/.config/ghostty"
  rsync -a --exclude='.git' "$DOTFILES_DIR/config/terminal/ghostty/" "$HOME/.config/ghostty/"
  echo "Copied config/terminal/ghostty to .config/ghostty"
fi

# Zellij
if [ -d "$DOTFILES_DIR/config/terminal/zellij" ]; then
  mkdir -p "$HOME/.config/zellij"
  rsync -a --exclude='.git' "$DOTFILES_DIR/config/terminal/zellij/" "$HOME/.config/zellij/"
  echo "Copied config/terminal/zellij to .config/zellij"
fi

# Git configuration
if [ -d "$DOTFILES_DIR/config/git" ]; then
  # Copy global gitignore
  if [ -f "$DOTFILES_DIR/config/git/.gitignore_global" ]; then
    cp "$DOTFILES_DIR/config/git/.gitignore_global" "$HOME/.gitignore_global"
    echo "Copied .gitignore_global"
  fi
  
  # Copy git config
  if [ -f "$DOTFILES_DIR/config/git/.gitconfig" ]; then
    cp "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
    echo "Copied .gitconfig"
  fi
fi

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all Brewfile packages
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Restore Cursor settings, keybindings, and extensions if present
CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor"
if [ -d "$DOTFILES_DIR/cursor-config" ]; then
  echo "Restoring Cursor user settings and keybindings..."
  mkdir -p "$CURSOR_CONFIG_DIR"
  rsync -a "$DOTFILES_DIR/cursor-config/" "$CURSOR_CONFIG_DIR/"
fi
if command -v cursor &>/dev/null && [ -f "$DOTFILES_DIR/cursor-extensions.txt" ]; then
  echo "Installing Cursor extensions..."
  cat "$DOTFILES_DIR/cursor-extensions.txt" | xargs -L 1 cursor --install-extension
fi

# Install nvm and latest LTS node
if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
echo "Installing latest LTS Node.js..."
nvm install --lts

# Install Zellij if not present
if ! command -v zellij &>/dev/null; then
  echo "Installing Zellij..."
  bash <(curl -L https://zellij.dev/launch)
fi

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install zsh-vi-mode plugin
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode" ]; then
  echo "Installing zsh-vi-mode plugin..."
  git clone https://github.com/jeffreytse/zsh-vi-mode.git "$HOME/.oh-my-zsh/custom/plugins/zsh-vi-mode"
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Copy custom plugins/themes
if [ -d "$DOTFILES_DIR/.oh-my-zsh/custom" ]; then
  rsync -a --exclude='.git' "$DOTFILES_DIR/.oh-my-zsh/custom/" "$HOME/.oh-my-zsh/custom/"
  echo "Copied Oh My Zsh custom plugins/themes"
fi

# Install Neovim plugins (headless)
if command -v nvim &>/dev/null; then
  echo "Installing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa || true
fi

echo "All done! Restart your terminal." 