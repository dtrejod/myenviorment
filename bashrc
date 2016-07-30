#
# ~/.bashrc
#



# If not running interactively, don't do anything
[[ $- != *i* ]] && return


PATH=$PATH:/home/dtrejo/.gem/ruby/2.3.0/bin
# Setup console prompt
export PS1="\[\033[38;5;20m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;2m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;160m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\][\v]\\$ \[$(tput sgr0)\]"

# Music Player settings
export ncmpcpp_directory="~/.config/ncmpcpp"

# Aliases
alias vi="vim"
alias rm="rm -i"
alias l="ls -lahF --color=auto"
alias dirs="dirs -v"
alias "tmuxk"="tmux kill-session -t"
alias "tmuxa"="tmux a -t"
alias "c"="clear"
alias "df"="df -hT"
alias "ncm"="ncmpcpp"
alias "nowplay"="ncmpcpp --current-song && echo ''"
