#!/bin/bash

echo "🔍 Validating dotfiles setup..."

# Check if required files exist
echo "📁 Checking file structure..."
[ -f "Brewfile" ] && echo "✅ Brewfile exists" || echo "❌ Brewfile missing"
[ -f "config/install.sh" ] && echo "✅ Install script exists" || echo "❌ Install script missing"
[ -f "config/zsh/.zshrc" ] && echo "✅ Zsh config exists" || echo "❌ Zsh config missing"
[ -d "config/editor/nvim" ] && echo "✅ Neovim config exists" || echo "❌ Neovim config missing"
[ -d "config/editor/Cursor" ] && echo "✅ Cursor config exists" || echo "❌ Cursor config missing"
[ -d "config/terminal/ghostty" ] && echo "✅ Ghostty config exists" || echo "❌ Ghostty config missing"
[ -d "config/terminal/zellij" ] && echo "✅ Zellij config exists" || echo "❌ Zellij config missing"
[ -d "config/git" ] && echo "✅ Git config exists" || echo "❌ Git config missing"
[ -f "config/git/.gitconfig" ] && echo "✅ Git config file exists" || echo "❌ Git config file missing"
[ -f "config/git/.gitignore_global" ] && echo "✅ Global gitignore exists" || echo "❌ Global gitignore missing"

# Check script syntax
echo ""
echo "🔧 Checking script syntax..."
bash -n config/install.sh && echo "✅ Install script syntax OK" || echo "❌ Install script syntax error"

# Check if Homebrew is available
echo ""
echo "🍺 Checking Homebrew availability..."
if command -v brew &>/dev/null; then
    echo "✅ Homebrew is installed"
    echo "📍 Homebrew prefix: $(brew --prefix)"
else
    echo "⚠️  Homebrew not installed (will be installed by script)"
fi

# Check current system
echo ""
echo "💻 System info:"
echo "   Architecture: $(uname -m)"
echo "   OS: $(uname -s)"
echo "   Shell: $SHELL"

echo ""
echo "🎯 Ready to test! Run: ./test-install.sh" 