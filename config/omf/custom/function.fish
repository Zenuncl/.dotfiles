# =============================================================================
# Custom Fish Functions
# Converted from bin/ shell scripts + original dotenv helper
# =============================================================================

# ─── mem ──────────────────────────────────────────────────────────────────
# Load a memory.log file which can temp remember some information
# Usage: dotenv add
# Usage: dotenv expiring
# Usage: dotenv <string> to search and get

function mem
    set FILE $WORKSPACE/$USER/memory.log

    mkdir -p (dirname $FILE)
    test -f $FILE; or touch $FILE

    # fzf --preview runs in sh — FS must escape | (regex OR), expiry is optional/last
    # Field order: date | type | tag | value | expiry(optional)
    set -l preview "echo {} | awk -F' \\| ' '{printf \"📅 Date     : %s\\n📦 Type     : %s\\n🏷️ Tag      : %s\\n📌 Value    : %s\\n\", \$1, \$2, \$3, \$4; if (\$5 != \"\") printf \"⏰ Expiry   : %s\\n\", \$5}'"

    switch $argv[1]

        case add
            set -e argv[1]
            set entry (string join " " $argv)
            echo (date "+%F")" | $entry" >> $FILE

        case expiring
            cat $FILE | awk -F" \\| " '
                function to_epoch(d) {
                    cmd = "date -d " d " +%s"
                    cmd | getline out
                    close(cmd)
                    return out
                }
                {
                    exp = $5
                    gsub("exp:", "", exp)
                    now = systime()
                    if (to_epoch(exp) - now < 1209600)
                        print $0
                }
            ' | fzf --preview $preview

        case '*'
            set query (string join " " $argv)

            if type -q fzf
                if test -n "$query"
                    set selected (rg $query $FILE | fzf --preview $preview)
                else
                    set selected (cat $FILE | fzf --preview $preview)
                end

                if test -n "$selected"
                    set value (echo $selected | awk -F" \\| " '{print $4}')

                    if type -q pbcopy
                        echo $value | pbcopy
                    else if type -q xclip
                        echo $value | xclip -selection clipboard
                    end

                    echo $selected
                end
            else
                cat $FILE
            end
    end
end

# ─── dotenv ──────────────────────────────────────────────────────────────────
# Load a .env file into the current fish session
# Usage: dotenv [file]   default: .env

function dotenv --description "Load .env into current fish session"
    set -l file (test -n "$argv[1]"; and echo $argv[1]; or echo ".env")
    if not test -f $file
        echo "dotenv ❌  $file not found" >&2
        return 1
    end

    for line in (string match -v '^\s*#' (cat $file | string trim -l -r))
        set -l kv (string split -m1 '=' $line)
        if test (count $kv) -eq 2
            set -gx $kv[1] $kv[2]
        end
    end
end


# =============================================================================
# ░░ SYSTEM CHECKS
# =============================================================================

# ─── check-cpu-usage ─────────────────────────────────────────────────────────
# Print current CPU usage percentage
# Usage: check-cpu-usage

function check-cpu-usage --description "Show current CPU usage %"
    set -l idle (top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
    set -l used (math 100 - $idle)
    echo "CPU: $used%"
end


# ─── check-ram-usage ─────────────────────────────────────────────────────────
# Print memory usage: % used, GB used, GB total
# Usage: check-ram-usage

function check-ram-usage --description "Show RAM usage (%, GB used, GB total)"
    free -m | grep Mem | awk '{
        printf "Memory: %.1f%% used — %.1f GB / %.1f GB total\n",
               $3/$2*100, $3/1000, $2/1000
    }'
end


# ─── check-sys-load ──────────────────────────────────────────────────────────
# Print system load averages (1m / 5m / 15m)
# Usage: check-sys-load

function check-sys-load --description "Show system load averages (1m/5m/15m)"
    uptime | awk -F 'load average:' '{print $2}' | tr -d ',' \
        | awk '{print "Load — 1m: "$1"  5m: "$2"  15m: "$3}'
end


# ─── check-disk-spaces ───────────────────────────────────────────────────────
# Print disk usage; warn on any partition ≥ 80%
# Usage: check-disk-spaces

function check-disk-spaces --description "Show disk usage, warn if ≥ 80%"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{print $5, $6}' \
        | while read -l usage mount
            echo "$usage $mount"
            set -l pct (string replace '%' '' $usage)
            if test $pct -ge 80
                echo "  ⚠ WARNING: $mount is at $usage"
            end
        end
end


# ─── check-large-files ───────────────────────────────────────────────────────
# Find files larger than 1 GB under a given path
# Usage: check-large-files <path>

function check-large-files --description "Find files > 1 GB under <path>"
    if test (count $argv) -eq 0
        echo "Usage: check-large-files <path>" >&2
        return 1
    end
    find $argv[1] -type f -size +1000M
end


# ─── check-band-usage ────────────────────────────────────────────────────────
# Print RX / TX bytes on the default route interface
# Usage: check-band-usage

function check-band-usage --description "Show RX/TX bandwidth on default interface"
    set -l iface (ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | head -1)
    if test -z "$iface"
        echo "Could not determine default interface." >&2
        return 1
    end
    ifconfig $iface \
        | awk '/RX.*bytes/{print "RX: " $5/1073741824 " GB"} /TX.*bytes/{print "TX: " $5/1073741824 " GB"}'
end


# ─── check-and-kill-ps ───────────────────────────────────────────────────────
# Kill all processes matching a name
# Usage: check-and-kill-ps <process-name>

function check-and-kill-ps --description "Kill all processes matching a name"
    if test (count $argv) -eq 0
        echo "Usage: check-and-kill-ps <process-name>" >&2
        return 1
    end
    set -l pids (ps auxf | grep $argv[1] | grep -v grep | awk '{print $2}')
    if test (count $pids) -eq 0
        echo "No processes found matching: $argv[1]"
        return 0
    end
    echo "Killing PIDs: $pids"
    kill $pids
end


# =============================================================================
# ░░ GIT HELPERS
# =============================================================================

# ─── git-co-pr ───────────────────────────────────────────────────────────────
# Fetch and checkout a GitHub pull request branch locally
# Usage: git-co-pr <pr-number>

function git-co-pr --description "Checkout a GitHub PR branch locally"
    if test (count $argv) -eq 0
        echo "Usage: git-co-pr <pr-number>" >&2
        return 1
    end
    set -l pr $argv[1]
    git fetch origin "pull/$pr/head:pr/$pr"
    and git checkout "pr/$pr"
end


# ─── git-pull-all ────────────────────────────────────────────────────────────
# Pull latest changes for every git repo found recursively from CWD
# Usage: git-pull-all

function git-pull-all --description "Pull all git repos found recursively from CWD"
    set -l cur_dir (pwd)
    echo "Pulling latest changes for all repositories under $cur_dir…"

    for git_dir in (find . -name ".git" | string replace '.git' '' | string replace -r '^\.' '')
        set -l repo_dir (string trim --chars='/' $git_dir)
        echo ""
        echo "── $repo_dir"
        cd "$cur_dir/$repo_dir"
        git fetch --all
        git pull origin (git rev-parse --abbrev-ref HEAD)
        cd $cur_dir
    end

    echo ""
    echo "Done."
end


# ─── git-wtf ─────────────────────────────────────────────────────────────────
# Display readable branch/remote relationship summary (Ruby script wrapper)
# Usage: git-wtf [branch] [options]

function git-wtf --description "Show git branch/remote state (git-wtf Ruby script)"
    ~/.bin/git-wtf $argv
end


# =============================================================================
# ░░ ENCRYPTION — ageit (age)
# =============================================================================

# ─── ageit ───────────────────────────────────────────────────────────────────
# Encrypt or decrypt files/dirs using age.
# Directories are tar'd (gzip) before encryption → name.gz.tar.age
# Plain files are encrypted directly              → name.ext.age
#
# Env vars:
#   AGE_KEYFILE           — default identity file for decryption
#   AGE_RECIPIENTS_FILE   — default recipients file for encryption
#                           (default: ~/.secrets/age/age-recipients.txt)
#
# Usage:
#   ageit --encrypt <file|dir> [--recipient <pubkey>]
#   ageit --decrypt <file.age> [--keyfile <path>]

function ageit --description "Encrypt/decrypt files with age"

    # ── dependency check ──────────────────────────────────────────────────
    if not type -q age
        echo "Error: 'age' is not installed." >&2
        return 1
    end

    # ── defaults ──────────────────────────────────────────────────────────
    set -l recipients_file (
        test -n "$AGE_RECIPIENTS_FILE"
        and echo $AGE_RECIPIENTS_FILE
        or echo "$HOME/.secrets/age/age-recipients.txt"
    )
    set -l keyfile_env (test -n "$AGE_KEYFILE"; and echo $AGE_KEYFILE; or echo "")

    # ── usage ─────────────────────────────────────────────────────────────
    function __ageit_usage
        echo "Usage:"
        echo "  ageit --encrypt <file|dir> [--recipient <pubkey>]"
        echo "  ageit --decrypt <file.age> [--keyfile <path>]"
        echo ""
        echo "Env: AGE_KEYFILE, AGE_RECIPIENTS_FILE"
    end

    # ── argument parsing ──────────────────────────────────────────────────
    set -l mode ""
    set -l file ""
    set -l recipient ""
    set -l keyfile_arg ""

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --encrypt
                set mode encrypt
                set i (math $i + 1)
                set file $argv[$i]
            case --decrypt
                set mode decrypt
                set i (math $i + 1)
                set file $argv[$i]
            case --recipient
                set i (math $i + 1)
                set recipient $argv[$i]
            case --keyfile
                set i (math $i + 1)
                set keyfile_arg $argv[$i]
            case --help
                __ageit_usage; return 0
            case '*'
                echo "Unknown option: $argv[$i]" >&2; __ageit_usage; return 1
        end
        set i (math $i + 1)
    end

    if test -z "$mode"
        echo "Error: specify --encrypt or --decrypt." >&2; __ageit_usage; return 1
    end
    if test -z "$file"
        echo "Error: no file specified." >&2; __ageit_usage; return 1
    end

    # ── encrypt ───────────────────────────────────────────────────────────
    if test "$mode" = encrypt
        if not test -e $file
            echo "Error: '$file' not found." >&2; return 1
        end

        set -l filedir (dirname $file)
        set -l base (basename $file)

        # Resolve recipient / recipients-file
        set -l age_args
        if test -n "$recipient"
            set age_args --recipient $recipient
            echo "Encrypting for recipient: $recipient"
        else if test -f $recipients_file
            set age_args --recipients-file $recipients_file
            echo "Encrypting using recipients file: $recipients_file"
        else
            read -P "Enter recipient public key (age1...): " recipient
            if test -z "$recipient"
                echo "Error: recipient required." >&2; return 1
            end
            set age_args --recipient $recipient
        end

        if test -d $file
            # Directory: tar czf → name.gz.tar → age → name.gz.tar.age
            set -l tar_out "$filedir/$base.gz.tar"
            set -l out "$tar_out.age"
            echo "Directory — archiving to $tar_out…"
            tar czf $tar_out -C $filedir $base
            and echo "Encrypting to $out…"
            and age $age_args --output $out $tar_out
            and rm -f $tar_out
            and echo "Encrypted: $out"
        else
            # Plain file: encrypt directly → name.ext.age
            set -l out "$filedir/$base.age"
            echo "File — encrypting to $out…"
            age $age_args --output $out $file
            and echo "Encrypted: $out"
        end

    # ── decrypt ───────────────────────────────────────────────────────────
    else if test "$mode" = decrypt
        if not test -f $file
            echo "Error: '$file' not found." >&2; return 1
        end

        # Resolve identity file: --keyfile > $AGE_KEYFILE > prompt
        set -l keyfile
        if test -n "$keyfile_arg"
            set keyfile $keyfile_arg
        else if test -n "$keyfile_env"
            set keyfile $keyfile_env
            echo "Using keyfile: $keyfile"
        else
            read -P "Enter path to identity (key) file: " keyfile
            if test -z "$keyfile"
                echo "Error: keyfile required." >&2; return 1
            end
        end

        if not test -f $keyfile
            echo "Error: keyfile '$keyfile' not found." >&2; return 1
        end

        set -l decrypted (string replace -r '\.age$' '' $file)
        age --decrypt --identity $keyfile --output $decrypted $file
        or return 1
        echo "Decrypted: $decrypted"

        # Extract only if it's a gzip tar (produced by our encrypt path)
        set -l mime (file --mime-type -b $decrypted)
        if string match -q "application/gzip" $mime; or string match -q "application/x-gzip" $mime
            echo "Detected gzip tar — extracting…"
            tar xzf $decrypted
            and rm -f $decrypted
        else
            echo "Not a tar archive ($mime), leaving as-is."
        end
    end
end


# =============================================================================
# ░░ PASSWORD MANAGERS
# =============================================================================

# ─── 1p ──────────────────────────────────────────────────────────────────────
# 1Password CLI helper — sign in, search items, lock
# Usage: 1p get <search-term>
#        1p lock

function 1p --description "1Password CLI helper (get / lock)"
    if not type -q op
        echo "Error: 'op' (1Password CLI) is not installed." >&2; return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: 1p get <search-term>" >&2
        echo "       1p lock" >&2
        return 1
    end

    switch $argv[1]
        case get
            if test (count $argv) -lt 2
                echo "Usage: 1p get <search-term>" >&2; return 1
            end
            echo "Signing in to 1Password…"
            eval (op signin)
            echo ""
            set -l matches (op item list | grep $argv[2])
            if test -z "$matches"
                echo "No items found matching: $argv[2]"
                return 0
            end
            echo $matches
            echo ""
            read -P "Enter item ID: " item_id
            echo ""
            op item get $item_id --reveal

        case lock
            echo "Locking 1Password…"
            op signout
            and echo "1Password locked."

        case '*'
            echo "Unknown action: $argv[1]" >&2
            echo "Usage: 1p get <term> | 1p lock" >&2
            return 1
    end
end


# ─── vw ──────────────────────────────────────────────────────────────────────
# Bitwarden CLI helper — search items, lock vault
# Usage: vw get <search-term>
#        vw lock

function vw --description "Bitwarden CLI helper (get / lock)"
    if not type -q bw
        echo "Error: 'bw' (Bitwarden CLI) is not installed." >&2; return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: vw get <search-term>" >&2
        echo "       vw lock" >&2
        return 1
    end

    switch $argv[1]
        case get
            if test (count $argv) -lt 2
                echo "Usage: vw get <search-term>" >&2; return 1
            end
            echo "Searching Bitwarden…"
            bw --pretty list items --search $argv[2]

        case lock
            echo "Locking Bitwarden…"
            bw lock
            and echo "Bitwarden locked."

        case '*'
            echo "Unknown action: $argv[1]" >&2
            echo "Usage: vw get <term> | vw lock" >&2
            return 1
    end
end


# =============================================================================
# ░░ NETWORKING
# =============================================================================

# ─── whats-in-port ───────────────────────────────────────────────────────────
# Show the process listening on a given TCP port
# Usage: whats-in-port <port>

function whats-in-port --description "Show process listening on a TCP port"
    if test (count $argv) -eq 0
        echo "Usage: whats-in-port <port>" >&2
        return 1
    end
    lsof -ni4TCP:$argv[1]
end


# ─── ddns ────────────────────────────────────────────────────────────────────
# Update Route 53 A record with the current public IP (Dynamic DNS)
# Requires: aws CLI (profile: ddns), jq, $DDNS_HOSTED_ZONE_ID env var
# Usage: ddns

function ddns --description "Update Route 53 DDNS A record with current public IP"
    if not type -q aws
        echo "Error: 'aws' CLI is not installed." >&2; return 1
    end
    if not type -q jq
        echo "Error: 'jq' is not installed." >&2; return 1
    end
    if test -z "$DDNS_HOSTED_ZONE_ID"
        echo "Error: \$DDNS_HOSTED_ZONE_ID is not set." >&2; return 1
    end

    set -l zone_id $DDNS_HOSTED_ZONE_ID
    set -l ttl 60
    set -l hostname (hostnamectl hostname)

    # Fetch public IP — try JSON parse first, fall back to raw
    set -l ipinfo (curl -fsSL https://ipinfo.io/what-is-my-ip)
    set -l ip (echo $ipinfo | jq -r '.ip' 2>/dev/null)
    if test -z "$ip" -o "$ip" = null
        set ip (echo $ipinfo | string trim)
    end

    # Validate IPv4 format
    if not string match -qr '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' $ip
        echo "Error: invalid IP address received: '$ip'" >&2; return 1
    end

    # Check current Route 53 value
    set -l current_ip (aws --profile ddns route53 list-resource-record-sets \
        --hosted-zone-id $zone_id --output json \
        | jq -r --arg h "$hostname." --arg t A \
            '.ResourceRecordSets[] | select(.Name==$h) | select(.Type==$t) | .ResourceRecords[0].Value')

    if test "$current_ip" = "$ip"
        echo "IP unchanged ($ip). No update needed."
        return 0
    end

    echo "Updating $hostname: $current_ip → $ip"

    aws --profile ddns route53 change-resource-record-sets \
        --hosted-zone-id $zone_id \
        --change-batch "{
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$hostname\",
                    \"Type\": \"A\",
                    \"TTL\": $ttl,
                    \"ResourceRecords\": [{\"Value\": \"$ip\"}]
                }
            }]
        }" > /dev/null
    and echo "DNS updated: $hostname → $ip"
end


# =============================================================================
# ░░ PYTHON VIRTUAL ENVIRONMENTS
# =============================================================================

# ─── venv ────────────────────────────────────────────────────────────────────
# Manage Python virtual environments under ~/dev/virtualenv/
# Fish uses activate.fish instead of bash's activate
#
# Usage:
#   venv <name>            Create (if needed) and activate
#   venv create|c <name>   Create only
#   venv activate|a <name> Activate only
#   venv deactivate|d      Deactivate current venv

function venv --description "Manage Python virtual environments"
    set -g base "$HOME/dev/env/python"

    if not type -q virtualenv
        echo "Error: 'virtualenv' is not installed. Run: pip install virtualenv" >&2
        return 1
    end

    # ── helpers ───────────────────────────────────────────────────────────
    function __venv_create -a name
        echo $base
        set -l path "$base/$name"
        if test -d $path
            echo "Virtual environment '$name' already exists at $path"
            return 0
        end
        read -P "Create virtual environment '$name' at $path? [y/N] " choice
        switch (string lower $choice)
            case y yes
                echo "Creating $path…"
                virtualenv $path
            case '*'
                echo "Cancelled."
        end
    end

    function __venv_activate -a name
        set -l path "$base/$name"
        if not test -d $path
            echo "Virtual environment '$name' not found at $path" >&2; return 1
        end
        # Fish virtual environments use activate.fish
        source "$path/bin/activate.fish"
        echo "Activated: $name ($path)"
    end

    function __venv_deactivate
        if test -z "$VIRTUAL_ENV"
            echo "No virtual environment is currently active."
        else
            deactivate
            echo "Deactivated."
        end
    end

    # ── dispatch ──────────────────────────────────────────────────────────
    if test (count $argv) -eq 0
        echo "Usage: venv <name>" >&2
        echo "       venv create|c <name>" >&2
        echo "       venv activate|a <name>" >&2
        echo "       venv deactivate|d" >&2
        return 1
    end

    switch $argv[1]
        case create c
            test (count $argv) -ge 2; or begin
                echo "Usage: venv create <name>" >&2; return 1
            end
            __venv_create $argv[2]
        case activate a
            test (count $argv) -ge 2; or begin
                echo "Usage: venv activate <name>" >&2; return 1
            end
            __venv_activate $argv[2]
        case deactivate d
            __venv_deactivate
        case '*'
            # Default: create-if-missing then activate
            __venv_create $argv[1]
            and __venv_activate $argv[1]
    end
    set -e path
end


# =============================================================================
# ░░ TERMINAL / WORKSPACE
# =============================================================================

# ─── start-zellij ────────────────────────────────────────────────────────────
# Start zellij via zellij-runner (if available) or attach to existing session
# Usage: start-zellij

function start-zellij --description "Start or attach to a Zellij session"
    if type -q zellij-runner
        ZELLIJ_RUNNER_LAYOUTS_DIR="$HOME/.config/zellij/layouts" \
        ZELLIJ_RUNNER_BANNERS_DIR="$HOME/.config/zellij/banners" \
        ZELLIJ_RUNNER_ROOT_DIR="$HOME/dev" \
        zellij-runner
    else
        zellij attach
    end
end


# ─── diff-so-fancy ───────────────────────────────────────────────────────────
# Pipe diff/git output through diff-so-fancy for pretty formatting
# This wraps the Perl script in bin/ — it's used as a git pager.
# Usage: git diff | diff-so-fancy
#        diff-so-fancy [options]

function diff-so-fancy --description "Pretty-print git diffs (diff-so-fancy Perl wrapper)"
    ~/.bin/diff-so-fancy $argv
end


# =============================================================================
# ░░ SECURITY / UTILITIES
# =============================================================================

# ─── passgen ─────────────────────────────────────────────────────────────────
# Generate a memorable passphrase: 4 random words + number + punctuation
# One word is randomly capitalised; separator is random (. or -)
# Usage: passgen

function passgen --description "Generate a password/token — usage: passgen [mem|token|rand]"
    set -l mode (test (count $argv) -gt 0; and echo $argv[1]; or echo mem)

    switch $mode

        case mem
            if not test -f /usr/share/dict/words
                echo "Error: /usr/share/dict/words not found." >&2; return 1
            end
            if not type -q shuf
                echo "Error: 'shuf' is not installed." >&2; return 1
            end

            # Total parts 5–7: 1 digits block + (total-1) words
            # random MIN MAX returns an integer in [MIN, MAX] inclusive
            set -l total_parts (random 5 7)
            set -l num_words   (math $total_parts - 1)

            # Sample words — exclude those containing apostrophes (octal 047)
            set -l words (shuf -n 100 /usr/share/dict/words | awk '!/\047/' | shuf -n $num_words)

            if test (count $words) -lt $num_words
                echo "Error: not enough words sampled from dictionary." >&2; return 1
            end

            # Randomly capitalise one word (fish arrays are 1-indexed)
            set -l cap_idx (random 1 $num_words)
            set words[$cap_idx] (string upper $words[$cap_idx])

            # Build 4–6 digit number using digits 2-9 only
            set -l num_digits (random 4 6)
            set -l digits
            for i in (seq $num_digits)
                set -a digits (random choice 2 3 4 5 6 7 8 9)
            end
            set -l number (string join "" $digits)

            # Insert number at a random position — not first, not last
            # valid: position 1 … (num_words-1), i.e. after word 1 up to before last word
            set -l max_pos (math $num_words - 1)
            set -l insert_pos (random 1 $max_pos)
            set -l parts
            for i in (seq $num_words)
                set -a parts $words[$i]
                if test $i -eq $insert_pos
                    set -a parts $number
                end
            end

            set -l sep   (random choice - .)
            set -l punct (random choice "!" "?")
            echo "Memorable Password: "(string join $sep $parts)$punct

        case token
            if not type -q openssl
                echo "Error: 'openssl' is not installed." >&2; return 1
            end
            echo "Token (hex 64): "(openssl rand -hex 64)

        case rand
            if not type -q pwgen
                echo "Error: 'pwgen' is not installed." >&2; return 1
            end
            echo "Random Password (64): "(pwgen -s 64 1)

        case '*'
            echo "Usage: passgen [mem|token|rand]" >&2
            echo "  mem   — memorable word-based passphrase (default)" >&2
            echo "  token — openssl hex 64 token" >&2
            echo "  rand  — pwgen 64-char random password" >&2
            return 1

    end
end

# ─── world_time ───────────────────────────────────────────────────────────────
# Display current time in UTC and 5 popular locations
# Usage: world_time

function world_time --description "Show current time across major timezones"
    set -l fmt "%Y-%m-%d %H:%M %Z"

    set -l locations \
        "UTC / GMT"                 "UTC" \
        "US Los Angeles (-7)"       "America/Los_Angeles" \
        "CA Toronto (-4)"           "Canada/Eastern" \
        "EU Paris (+1)"             "Europe/Paris" \
        "AE Dubai (+4)"             "Asia/Dubai" \
        "CN Hong Kong (+8)"         "Asia/Hong_Kong" \
        "JP Tokyo (+9)"             "Asia/Tokyo" \
        "AU Sydney (+11)"           "Australia/Sydney"

    printf "%-20s  %s\n" "Location" "Local Time"
    printf "%-20s  %s\n" "--------------" "-------------------"

    set -l i 1
    while test $i -le (count $locations)
        set -l label $locations[$i]
        set -l tz    $locations[(math $i + 1)]
        set -l time  (TZ=$tz date +"$fmt")
        printf "%-20s  %s\n" $label $time
        set i (math $i + 2)
    end
end

# ─── s3_backup ───────────────────────────────────────────────────────────────
# Backup a local directory to S3, scoped under a short hostname alias
# Usage: s3_backup <local_dir> [s3_bucket]
#   local_dir  — path to sync (required)
#   s3_bucket  — bucket name (default: webs-data)
function s3_backup --description "Sync a local directory to S3 under hostname/dir"
    if not type -q aws
        echo "s3_backup: error: 'aws' CLI not found. Install it or check your PATH." >&2
        return 1
    end

    if test (count $argv) -lt 1
        echo "Usage: s3_backup <local_dir> [s3_bucket]" >&2
        return 1
    end

    set -l local_dir $argv[1]
    set -l bucket    (test (count $argv) -ge 2; and echo $argv[2]; or echo "webs-data")

    if not test -d $local_dir
        echo "s3_backup: error: '$local_dir' is not a directory." >&2
        return 1
    end

    # Short hostname (e.g. "web01") as path prefix
    set -l host  (hostname -s)
    set -l base  (basename $local_dir)
    set -l s3dst "s3://$bucket/$host/$base"

    echo "Syncing $local_dir -> $s3dst"
    aws --profile web s3 sync $local_dir $s3dst
end


