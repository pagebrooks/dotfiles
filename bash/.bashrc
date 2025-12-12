case $- in
  *i*) ;;
    *) return ;;
esac
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

# Environment Variables
export EDITOR="vim"

# Aliases
alias la='eza -a'
alias ll='eza -l'
alias lla='eza -la'
# alias ls='eza'
alias lt='eza --tree'
alias mktmpd='cd $(mktemp -d)'
alias mktmpf='$EDITOR $(mktemp)'
alias myip6='echo "$(curl -sSL api6.ipify.org)"'
alias myip='echo "$(curl -sSL api.ipify.org)"'
alias newguid='uuidgen'
alias top='htop'

alias vim='nvim'
alias vi='nvim'
alias myprofile='nvim ~/.bashrc'
alias weather='curl https://wttr.in'

export PATH="$HOME/.local/bin:$PATH"