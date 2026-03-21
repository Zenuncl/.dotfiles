if test -d $HOME/.ssh/secrets/keys.sec
  echo (set_color green)"✓ Secrets SSH Exist, Loaded..."(set_color normal)
  ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
end
