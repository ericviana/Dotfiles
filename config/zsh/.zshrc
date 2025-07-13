# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
export GPG_TTY=$(tty)
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# Source modular configs
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/paths.zsh
source ~/.zsh/scheduling.zsh

# Source private environment variables (if file exists)
[[ -f ~/.zsh/env.private ]] && source ~/.zsh/env.private

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Syntax highlighting and autosuggestions
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Vi mode
set -o vi

# FZF
eval "$(fzf --zsh)" 

# bun completions
[ -s "/Users/eric/.bun/_bun" ] && source "/Users/eric/.bun/_bun"
