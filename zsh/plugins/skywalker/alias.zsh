# Aliases Set Up

# UTC time check
alias utc_time="TZ='Etc/UTC' date"
alias utc_chrome="TZ='Etc/UTC' open -na 'Google Chrome' --args '--user-data-dir=$HOME/.chrome-testing-profile'"

# System level alias
alias reload!=". $HOME/.zshrc"
alias less="less -R" # -R preserves ANSI color escape sequences in output
alias grep="grep --color=auto"
alias ff="find . -type f -name" # Fast find
alias du="du -h"
alias df="df -h"
alias javac="javac -J-Dfile.encoding=utf8"

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
alias dnsmasq.load="sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist"
alias dnsmasq.unload="sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist"
alias dnscrypt.unload="sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist"
alias dnscrypt.load="sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist"
alias last.command='fc -ln -1 | pbcopy'