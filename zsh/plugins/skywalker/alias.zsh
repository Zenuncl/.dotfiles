# Aliases Set Up

# UTC time check
alias utc_time="TZ='Etc/UTC' date"
alias nyc_time="TZ='Canada/Eastern' date"
alias sha_time="TZ='Asia/Shanghai' date"
alias par_time="TZ='Europe/Paris' date"
alias tyo_time="TZ='Asia/Tokyo' date"
alias utc_chrome="TZ='Etc/UTC' open -na 'Google Chrome' --args '--user-data-dir=$HOME/.chrome-testing-profile'"

# System level alias
alias reload!=". $HOME/.zshrc"
alias less="less -R" # -R preserves ANSI color escape sequences in output
alias grep="grep --color=auto"
alias ff="find . -type f -name" # Fast find
alias du="du -h"
alias df="df -h"
alias javac="javac -J-Dfile.encoding=utf8"
alias ls='ls --color=auto'
alias free="free -h"
alias top="htop"
alias ps="ps auxf"
#alias vi="vim"
alias vi="nvim"
alias nvi="nvim"
alias mutt="neomutt"
alias c="clear"
alias x="exit"
alias h="history -20"
alias hc="history -c"
alias hg="history | grep"
alias ag="alias | grep"
alias t="htop || top"
alias which="type -a"
alias curl="curlie"

# Change directory
alias pud="pushd"
alias ppd="popd"

# Other useful alias
alias latex="docker run --rm --volume "$(pwd):/data" --user $(id -u):$(id -g) pandoc/latex"

# Global alias
alias -g G="| grep"
alias -g L="| less"
alias -g C="| column -t"

# File alias
alias -s gz='tar -xzvf'
alias -s tgz='tar -xzvf'
alias -s zip='unzip'
alias -s bz2='tar -xjvf'

# Default File opener alias
alias -s html=vim
alias -s rb=vim
alias -s py=vim
alias -s js=vim
alias -s css=vim
alias -s c=vim
alias -s java=vim
alias -s php=vim
alias -s txt=vim

# User configuration
alias last.command='fc -ln -1'
alias ll="ls -lh"
alias la="ls -lha"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias mkdir="mkdir -p"
alias ..="cd .."
alias ...="cd ../../"
alias vi="vim"
alias weather="curl wttr.in"
alias ipinfo="curl ipinfo.io"
alias ffs-"sudo !!"
