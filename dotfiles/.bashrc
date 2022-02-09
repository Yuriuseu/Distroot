[[ $- != *i* ]] && return

shopt -s extglob

export HISTCONTROL=ignoreboth:erasedups
export PS1="┌── \e[1;92m\u\e[97m@\e[92m\h \e[94m\w\e[m\n└─• "

alias ls="ls -h --color=auto --group-directories-first"
alias tree="tree -C --dirsfirst"
