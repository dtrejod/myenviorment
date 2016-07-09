#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias vi='vim'
PATH=$PATH:/home/dtrejo/.gem/ruby/2.3.0/bin
export PS1="\[\033[38;5;20m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;2m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;160m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\][\v]\\$ \[$(tput sgr0)\]"

alias rm="rm -i"
alias l="ls -lahF --color=auto"
alias dirs="dirs -v"
alias "tmuxk"="tmux kill-session -t"
alias "tmuxa"="tmux a -t"
alias "c"="clear"
