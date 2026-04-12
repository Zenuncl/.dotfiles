# Only load when interactive shell
status is-interactive || exit

# Load global .env variable if exist
if test -f $HOME/.secrets/.env
    echo (set_color green)"✓ Secrets ENV Exist, Loaded..."(set_color normal)
    while read -l line
        # 1. Skip comments and empty lines
        if not string match -q -r '^#|^$' "$line"
            # 2. Split into key and value
            set -l item (string split -m 1 '=' $line)
            set -l key $item[1]
            set -l val $item[2]

            # 3. Use eval to expand variables like $HOME
            eval set -gx $key $val
        end
    end < $HOME/.secrets/.env
end

# Load global ssh keys if exist
if test -d $HOME/.ssh/secrets/keys.sec
  echo (set_color green)"✓ Secrets SSH Exist, Loaded..."(set_color normal)
  ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
end

# When INTERACTIVE, load tmux session

if status is-interactive
    and test "$USER" = "zenuncl"
    and test "$hostname" = "zeus-dev.ams.atlas.ethe.net"
    and test -z "$TMUX"
    and test -z "$SKIP_TMUX"
    tmux new-session -A -t Workspaces
end
