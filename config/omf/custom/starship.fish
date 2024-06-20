# Loads starship if starship is installed. Does nothing if 
# starship is not installed

status is-interactive || exit

if type -t starship > /dev/null  
  if test "$HOME/.config/starship/starship.toml"
    set --global --export STARSHIP_CONFIG $HOME/.config/starship/starship.toml
  end  
  starship init fish | source
end
