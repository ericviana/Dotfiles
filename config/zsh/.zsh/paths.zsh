# Ruby paths
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# Use a more flexible Ruby gems path that works with different versions
export PATH="/opt/homebrew/lib/ruby/gems/*/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Pipx
export PATH="$PATH:$HOME/.local/bin"

# Powerlevel10k settings
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off 