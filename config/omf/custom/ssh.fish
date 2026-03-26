if test -d $HOME/.ssh/secrets/keys.sec
  echo (set_color green)"✓ Secrets SSH Exist, Loaded..."(set_color normal)
  ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
end

if status is-interactive
    and test "$USER" = "zenuncl"
    and test "$hostname" = "zeus-dev.ams.atlas.ethe.net"
    and test -z "$TMUX"
    and test -z "$SKIP_TMUX"
    tmux new-session -A -t Workspaces
end
