# Aliases Set Up

# Fish
alias fishp="fish --private"

# UTC time check
alias utc_time="TZ='Etc/UTC' date"
alias nyc_time="TZ='Canada/Eastern' date"
alias sha_time="TZ='Asia/Shanghai' date"
alias par_time="TZ='Europe/Paris' date"
alias tyo_time="TZ='Asia/Tokyo' date"

# System level alias
alias less="less --raw-control-chars" # -R preserves ANSI color escape sequences in output
alias grep="grep --color=auto"
alias ff="find . -type f -name" # Fast find
alias du="du --human-readable"
alias df="df --human-readable"
alias javac="javac -J-Dfile.encoding=utf8"
alias ls="ls -all --human-readable --color=auto"
alias ll="ls -l --human-readable --color=auto"
alias la="ls -l --all --human-readable --color=auto"
alias free="free --human"
alias ps="ps auxf"
alias c="clear"
alias x="exit"
alias h="history -20"
alias hc="history --contains"
alias hg="history | grep"
alias ag="alias | grep"
alias t="htop || top"
alias which="type --all"

# Change directory
alias pud="pushd"
alias ppd="popd"

# Other useful alias
alias latex="docker run --rm --volume "$(pwd):/data" --user $(id -u):$(id -g) pandoc/latex"

# File alias
alias gz='tar -xzvf'
alias tgz='tar -xzvf'
alias zip='unzip'
alias bz2='tar -xjvf'

# User configuration
alias top="htop"
alias cat='bat --theme=ansi'
alias cp="cp --interactive"
alias mv="mv --interactive"
alias rm="rm --interactive"
alias mkdir="mkdir --parents"
alias weather="curl wttr.in"
alias ipinfo="curl ipinfo.io"
alias vi="nvim"
alias vim="nvim"
alias nvi="nvim"
alias mutt="neomutt"
alias curl="curlie || curl"
alias zj="start-zellij"
