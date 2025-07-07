#!/bin/bash
set -e

echo "🧪 Testing dotfiles installation..."
echo "This will backup your current configs and test the installation"

# Create backup directory
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Backing up current configs to $BACKUP_DIR"

# Backup existing configs
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
[ -d "$HOME/.zsh" ] && cp -r "$HOME/.zsh" "$BACKUP_DIR/"
[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/"
[ -d "$HOME/.config/Cursor" ] && cp -r "$HOME/.config/Cursor" "$BACKUP_DIR/"
[ -d "$HOME/.config/ghostty" ] && cp -r "$HOME/.config/ghostty" "$BACKUP_DIR/"
[ -d "$HOME/.config/zellij" ] && cp -r "$HOME/.config/zellij" "$BACKUP_DIR/"
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
[ -f "$HOME/.gitignore_global" ] && cp "$HOME/.gitignore_global" "$BACKUP_DIR/"

echo "✅ Backup created at $BACKUP_DIR"

# Test the installation
echo "🚀 Running installation test..."
./config/install.sh

echo ""
echo "🎉 Test completed!"
echo "📋 To restore your original configs:"
echo "   cp -r $BACKUP_DIR/.zshrc $HOME/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/.zsh $HOME/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/nvim $HOME/.config/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/Cursor $HOME/.config/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/ghostty $HOME/.config/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/zellij $HOME/.config/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/.gitconfig $HOME/ 2>/dev/null || true"
echo "   cp -r $BACKUP_DIR/.gitignore_global $HOME/ 2>/dev/null || true" 