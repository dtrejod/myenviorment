#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ---------
# - SHELL -
# ---------

# Setup Default Editor
export EDITOR=vim
export VISAUL="$EDITOR"

# less override
LESSOPEN="|lesspipe.sh %s"; export LESSOPEN

# Setup Terminal
export TERM=screen-256color

# Allow for search forward
stty -ixon

# --------------
# - Setup Path -
# --------------
# Path: Django?
PATH=$PATH:/home/dtrejo/.gem/ruby/2.3.0/bin

# Path: Custom binaries
PATH=$PATH:/home/dtrejo/bin

# ----------
# - Python -
# ----------
# Virtualenv setup
export WORKON_HOME=~/.virtualenvs
. /usr/bin/virtualenvwrapper.sh

# OpenCV
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

# ----------------
# - Setup Prompt -
# ----------------
export PS1="\[\033[38;5;20m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;2m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;160m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\][$SHLVL]\\$ \[$(tput sgr0)\]"

# --------
# - DIRS -
# --------
pushd /home/dtrejo/documents/projects > /dev/null
cd ~

# ---------
# - MUSIC -
# ---------
# Music Player settings
export ncmpcpp_directory="~/.config/ncmpcpp"

# -----------
# - Aliases -
# -----------
alias vi="vim"
alias rm="rm -i"
alias l="ls -hF --color=auto"
alias ll="ls -lhF --color=auto"
alias la="ls -lahF --color=auto"
alias dirs="dirs -v"
alias "tmuxk"="tmux kill-session -t"
alias "tmuxa"="tmux a -t"
alias "c"="clear"
alias "df"="df -hT"
alias "ncm"="ncmpcpp"
alias "nowplay"="ncmpcpp --current-song && echo ''"
alias "pdf"=evince
alias "..."="cd ../.."
alias ".."="cd .."
