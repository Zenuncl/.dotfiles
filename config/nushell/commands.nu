# =============================================================================
# Nushell Custom Commands
# Equivalent to config/omf/custom/function.fish
#
# Key Nushell differences from Fish:
#   - `def` for commands, `def --env` for commands that mutate environment
#   - `input` instead of `read -P` for interactive prompts
#   - `$env.HOME` instead of `$HOME`
#   - String interpolation: $"text ($var) text"
#   - Last expression in a def is the return value (no explicit `return`)
#   - `mut` for reassignable variables, `let` for immutable
#   - `^cmd` to force-call an external binary
# =============================================================================


# =============================================================================
# ░░ ENVIRONMENT
# =============================================================================

# ─── dotenv ──────────────────────────────────────────────────────────────────
# Load a .env file into the current Nushell session.
# Usage: dotenv          # loads .env in CWD
#        dotenv path/to/file

def --env dotenv [
    file?: string  # path to .env file (default: .env)
] {
    let target = ($file | default ".env")
    if not ($target | path exists) {
        error make { msg: $"dotenv: ($target) not found" }
    }

    let env_map = (
        open $target
        | lines
        | where { |line|
            let t = ($line | str trim)
            ($t | str length) > 0 and not ($t | str starts-with '#')
        }
        | each { |line|
            let parts = ($line | split row -n 2 '=')
            if ($parts | length) == 2 {
                { key: ($parts | first | str trim), val: ($parts | last | str trim) }
            }
        }
        | compact
        | reduce --fold {} { |item, acc| $acc | insert $item.key $item.val }
    )
    load-env $env_map
    print $"Loaded ($env_map | columns | length) variables from ($target)"
}


# =============================================================================
# ░░ HISTORY HELPERS
# =============================================================================

# ─── h ───────────────────────────────────────────────────────────────────────
# Show last 20 history entries.
# Defined as a def (not alias) because aliases cannot contain pipes in Nushell.
# Usage: h

def h [] {
    history | last 20
}


# ─── hg / hc ─────────────────────────────────────────────────────────────────
# Search command history by substring.
# Usage: hg ssh
#        hc git

def hg [term: string] {
    history | where command =~ $term
}

def hc [term: string] {
    history | where command =~ $term
}

# ─── ag ──────────────────────────────────────────────────────────────────────
# Search defined aliases by name.
# Usage: ag git

def ag [term: string] {
    scope aliases | where name =~ $term
}


# =============================================================================
# ░░ SYSTEM CHECKS
# =============================================================================

# ─── check-cpu-usage ─────────────────────────────────────────────────────────
# Print current CPU usage % using Nushell's built-in sys.
# Usage: check-cpu-usage

def check-cpu-usage [] {
    let usage = (sys cpu | get cpu_usage | math avg | math round --precision 1)
    $"CPU: ($usage)%"
}


# ─── check-ram-usage ─────────────────────────────────────────────────────────
# Print memory usage: %, GB used, GB total using Nushell's built-in sys.
# Usage: check-ram-usage

def check-ram-usage [] {
    let mem       = (sys mem)
    let used      = $mem.used
    let total     = $mem.total
    let pct       = ($used / $total * 100 | math round --precision 1)
    let used_gb   = ($used / 1073741824 | math round --precision 2)
    let total_gb  = ($total / 1073741824 | math round --precision 2)
    $"Memory: ($pct)% used — ($used_gb) GB / ($total_gb) GB total"
}


# ─── check-sys-load ──────────────────────────────────────────────────────────
# Print system load averages (1m / 5m / 15m) using Nushell's built-in sys.
# Usage: check-sys-load

def check-sys-load [] {
    let load = (sys host | get load_avg)
    $"Load — 1m: ($load.1min)  5m: ($load.5min)  15m: ($load.15min)"
}


# ─── check-disk-spaces ───────────────────────────────────────────────────────
# Print disk usage for all real mounts; warn on partitions >= 80%.
# Usage: check-disk-spaces

def check-disk-spaces [] {
    sys disk | each { |disk|
        let pct = ($disk.used / $disk.total * 100 | math round)
        let line = $"($pct)% ($disk.device)"
        print $line
        if $pct >= 80 {
            print $"  ⚠ WARNING: ($disk.device) is at ($pct)%"
        }
    }
    null
}


# ─── check-large-files ───────────────────────────────────────────────────────
# Find files larger than 1 GB under a given path.
# Usage: check-large-files /var/log

def check-large-files [
    path: string  # directory to search
] {
    ^find $path -type f -size +1000M
}


# ─── check-band-usage ────────────────────────────────────────────────────────
# Print RX / TX bytes on the default-route network interface.
# Usage: check-band-usage

def check-band-usage [] {
    let iface = (
        ^ip route get 1.1.1.1
        | str trim
        | parse --regex '(?<=dev\s)\w+'
        | first
        | get capture0
    )
    if ($iface | is-empty) {
        error make { msg: "Could not determine default network interface" }
    }
    ^ifconfig $iface
    | lines
    | where { |l| ($l | str contains "RX") or ($l | str contains "TX") }
    | where { |l| $l | str contains "bytes" }
    | each { |l|
        let gb = ($l | parse --regex '(\d+)\s+bytes' | first | get capture0 | into float) / 1073741824
        let dir = if ($l | str contains "RX") { "RX" } else { "TX" }
        $"($dir): ($gb | math round --precision 3) GB"
    }
    | str join "\n"
    | print $in
}


# ─── check-and-kill-ps ───────────────────────────────────────────────────────
# Kill all processes matching a name string.
# Usage: check-and-kill-ps nginx

def check-and-kill-ps [
    process_name: string  # process name to search for
] {
    let pids = (
        ^ps auxf
        | lines
        | where { |l| ($l | str contains $process_name) and not ($l | str contains "grep") }
        | each { |l| $l | split row -r '\s+' | get 1 | str trim }
        | compact
    )
    if ($pids | is-empty) {
        print $"No processes found matching: ($process_name)"
        return
    }
    print $"Killing PIDs: ($pids | str join ', ')"
    for pid in $pids {
        ^kill $pid
    }
}


# =============================================================================
# ░░ GIT HELPERS
# =============================================================================

# ─── git-co-pr ───────────────────────────────────────────────────────────────
# Fetch and checkout a GitHub pull request branch locally.
# Usage: git-co-pr 123

def git-co-pr [
    pr: int  # pull request number
] {
    ^git fetch origin $"pull/($pr)/head:pr/($pr)"
    ^git checkout $"pr/($pr)"
}


# ─── git-pull-all ────────────────────────────────────────────────────────────
# Pull latest changes for every git repo found recursively from CWD.
# Usage: git-pull-all

def git-pull-all [] {
    let cur = (pwd)
    print $"Pulling all repositories under ($cur)…"

    ^find . -name ".git" -type d
    | lines
    | each { |git_dir|
        let repo = ($git_dir | str replace '/.git' '' | str replace -r '^\.' '' | str trim --char '/')
        print $"\n── ($repo)"
        cd $"($cur)/($repo)"
        ^git fetch --all
        let branch = (^git rev-parse --abbrev-ref HEAD | str trim)
        ^git pull origin $branch
        cd $cur
    }

    print "\nDone."
}


# ─── git-wtf ─────────────────────────────────────────────────────────────────
# Display readable branch/remote relationship summary.
# Wraps the Ruby script at ~/.bin/git-wtf.
# Usage: git-wtf [branch] [--long] [--short] [--all] [--relations]

def git-wtf [...args: string] {
    ^($env.HOME | path join ".bin" "git-wtf") ...$args
}


# =============================================================================
# ░░ ENCRYPTION — ageit (age)
# =============================================================================

# ─── ageit ───────────────────────────────────────────────────────────────────
# Encrypt or decrypt files/dirs using age.
#   Directories → tar (gzip) → name.gz.tar.age
#   Plain files → name.ext.age  (direct, no tar)
#
# Env vars:
#   AGE_KEYFILE           default identity file for decryption
#   AGE_RECIPIENTS_FILE   default recipients file for encryption
#
# Usage:
#   ageit encrypt <file|dir> [--recipient <pubkey>]
#   ageit decrypt <file.age>  [--keyfile <path>]

def ageit [
    mode: string              # encrypt | decrypt
    file: string              # file or directory to process
    --recipient(-r): string   # recipient public key (encrypt)
    --keyfile(-k): string     # identity file path (decrypt)
] {
    # ── dependency check ──────────────────────────────────────────────────
    if not (which age | is-empty | not $in) {
        error make { msg: "'age' is not installed" }
    }

    match $mode {

        # ── encrypt ───────────────────────────────────────────────────────
        "encrypt" => {
            if not ($file | path exists) {
                error make { msg: $"'($file)' not found" }
            }

            let filedir = ($file | path dirname)
            let base    = ($file | path basename)

            # Resolve recipient args: flag > env file > prompt
            let recipients_file = (
                $env | get -i AGE_RECIPIENTS_FILE | default ($env.HOME | path join ".secrets" "age" "age-recipients.txt")
            )
            let age_args = if ($recipient | is-empty | not $in) {
                ["--recipient" $recipient]
            } else if ($recipients_file | path exists) {
                ["--recipients-file" $recipients_file]
            } else {
                let r = (input "Enter recipient public key (age1...): " | str trim)
                if ($r | is-empty) { error make { msg: "recipient required" } }
                ["--recipient" $r]
            }

            if ($file | path type) == "dir" {
                # Directory: tar czf → name.gz.tar → age → name.gz.tar.age
                let tar_out = $"($filedir)/($base).gz.tar"
                let out     = $"($tar_out).age"
                print $"Directory — archiving to ($tar_out)…"
                ^tar czf $tar_out -C $filedir $base
                print $"Encrypting to ($out)…"
                ^age ...$age_args --output $out $tar_out
                ^rm -f $tar_out
                print $"Encrypted: ($out)"
            } else {
                # Plain file: encrypt directly → name.ext.age
                let out = $"($filedir)/($base).age"
                print $"File — encrypting to ($out)…"
                ^age ...$age_args --output $out $file
                print $"Encrypted: ($out)"
            }
        }

        # ── decrypt ───────────────────────────────────────────────────────
        "decrypt" => {
            if not ($file | path exists) {
                error make { msg: $"'($file)' not found" }
            }

            # Resolve identity: --keyfile flag > $AGE_KEYFILE env > prompt
            let kf = if ($keyfile | is-empty | not $in) {
                $keyfile
            } else if ($env | get -i AGE_KEYFILE | is-empty | not $in) {
                let k = ($env | get AGE_KEYFILE)
                print $"Using keyfile: ($k)"
                $k
            } else {
                let k = (input "Enter path to identity (key) file: " | str trim)
                if ($k | is-empty) { error make { msg: "keyfile required" } }
                $k
            }

            if not ($kf | path exists) {
                error make { msg: $"keyfile '($kf)' not found" }
            }

            let decrypted = ($file | str replace -r '\.age$' '')
            ^age --decrypt --identity $kf --output $decrypted $file
            print $"Decrypted: ($decrypted)"

            # Extract only if it's a gzip tar (from our encrypt path)
            let mime = (^file --mime-type -b $decrypted | str trim)
            if $mime == "application/gzip" or $mime == "application/x-gzip" {
                print "Detected gzip tar — extracting…"
                ^tar xzf $decrypted
                ^rm -f $decrypted
            } else {
                print $"Not a tar archive (($mime)), leaving as-is."
            }
        }

        _ => {
            error make { msg: $"Unknown mode '($mode)' — use: encrypt | decrypt" }
        }
    }
}


# =============================================================================
# ░░ PASSWORD MANAGERS
# =============================================================================

# ─── 1p ──────────────────────────────────────────────────────────────────────
# 1Password CLI helper — get items or lock the vault.
# Usage: 1p get <search-term>
#        1p lock

def 1p [
    action: string        # get | lock
    search?: string       # search term (required for 'get')
] {
    if not (^which op | complete | get exit_code) == 0 {
        error make { msg: "'op' (1Password CLI) is not installed" }
    }

    match $action {
        "get" => {
            if ($search | is-empty) {
                error make { msg: "Usage: 1p get <search-term>" }
            }
            print "Signing in to 1Password…"
            ^op signin
            print ""
            let matches = (^op item list | lines | where { |l| $l | str contains $search })
            if ($matches | is-empty) {
                print $"No items found matching: ($search)"
                return
            }
            $matches | each { |m| print $m }
            print ""
            let item_id = (input "Enter item ID: " | str trim)
            print ""
            ^op item get $item_id --reveal
        }
        "lock" => {
            print "Locking 1Password…"
            ^op signout
            print "1Password locked."
        }
        _ => {
            error make { msg: $"Unknown action '($action)' — use: get | lock" }
        }
    }
}


# ─── vw ──────────────────────────────────────────────────────────────────────
# Bitwarden CLI helper — search items or lock the vault.
# Usage: vw get <search-term>
#        vw lock

def vw [
    action: string        # get | lock
    search?: string       # search term (required for 'get')
] {
    if not (^which bw | complete | get exit_code) == 0 {
        error make { msg: "'bw' (Bitwarden CLI) is not installed" }
    }

    match $action {
        "get" => {
            if ($search | is-empty) {
                error make { msg: "Usage: vw get <search-term>" }
            }
            print "Searching Bitwarden…"
            ^bw --pretty list items --search $search
        }
        "lock" => {
            print "Locking Bitwarden…"
            ^bw lock
            print "Bitwarden locked."
        }
        _ => {
            error make { msg: $"Unknown action '($action)' — use: get | lock" }
        }
    }
}


# =============================================================================
# ░░ NETWORKING
# =============================================================================

# ─── whats-in-port ───────────────────────────────────────────────────────────
# Show the process listening on a given TCP port.
# Usage: whats-in-port 3000

def whats-in-port [
    port: int  # TCP port number
] {
    ^lsof -ni4TCP:$"($port)"
}


# ─── ddns ────────────────────────────────────────────────────────────────────
# Update a Route 53 A record with the current public IP (Dynamic DNS).
# Requires: aws CLI (profile: ddns), jq, $DDNS_HOSTED_ZONE_ID env var.
# Usage: ddns

def ddns [] {
    if not (^which aws | complete | get exit_code) == 0 {
        error make { msg: "'aws' CLI is not installed" }
    }
    if not (^which jq | complete | get exit_code) == 0 {
        error make { msg: "'jq' is not installed" }
    }

    let zone_id = ($env | get -i DDNS_HOSTED_ZONE_ID)
    if ($zone_id | is-empty) {
        error make { msg: "$DDNS_HOSTED_ZONE_ID is not set" }
    }

    let ttl      = 60
    let hostname = (^hostnamectl hostname | str trim)

    # Fetch public IP — try JSON parse, fall back to raw text
    let ipinfo = (^curl -fsSL https://ipinfo.io/what-is-my-ip | str trim)
    let ip = try {
        $ipinfo | from json | get ip
    } catch {
        $ipinfo
    }

    # Validate IPv4 format
    if not ($ip | str trim | parse --regex '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' | is-empty | not $in) {
        error make { msg: $"Invalid IP address received: '($ip)'" }
    }

    # Check current Route 53 record
    let current_ip = (
        ^aws --profile ddns route53 list-resource-record-sets
            --hosted-zone-id $zone_id --output json
        | from json
        | get ResourceRecordSets
        | where { |r| $r.Name == $"($hostname)." and $r.Type == "A" }
        | first
        | get ResourceRecords
        | first
        | get Value
    )

    if $current_ip == $ip {
        print $"IP unchanged (($ip)). No update needed."
        return
    }

    print $"Updating ($hostname): ($current_ip) → ($ip)"

    let change_batch = {
        Changes: [{
            Action: "UPSERT"
            ResourceRecordSet: {
                Name: $hostname
                Type: "A"
                TTL: $ttl
                ResourceRecords: [{ Value: $ip }]
            }
        }]
    }

    ^aws --profile ddns route53 change-resource-record-sets
        --hosted-zone-id $zone_id
        --change-batch ($change_batch | to json) out+err> /dev/null

    print $"DNS updated: ($hostname) → ($ip)"
}


# =============================================================================
# ░░ PYTHON VIRTUAL ENVIRONMENTS
# =============================================================================

# ─── venv ────────────────────────────────────────────────────────────────────
# Manage Python virtual environments under ~/dev/virtualenv/.
#
# Nushell note: activation modifies $env.PATH and $env.VIRTUAL_ENV directly
# via `def --env`, which persists to the calling scope (equivalent of
# fish's `source activate.fish`).
#
# Usage:
#   venv <name>             create (if needed) and activate
#   venv create <name>      create only
#   venv activate <name>    activate only
#   venv deactivate         deactivate current venv

def --env venv [
    action: string   # create | activate | deactivate | <name>
    name?: string    # virtual environment name
] {
    let base = ($env.HOME | path join "dev" "virtualenv")

    if not (^which virtualenv | complete | get exit_code) == 0 {
        error make { msg: "'virtualenv' is not installed. Run: pip install virtualenv" }
    }

    # Inner helper: create
    let do_create = { |vname|
        let vpath = ($base | path join $vname)
        if ($vpath | path exists) {
            print $"Virtual environment '($vname)' already exists at ($vpath)"
        } else {
            let choice = (input $"Create '($vname)' at ($vpath)? [y/N] " | str trim | str downcase)
            if $choice == "y" or $choice == "yes" {
                print $"Creating ($vpath)…"
                ^virtualenv $vpath
            } else {
                print "Cancelled."
            }
        }
    }

    # Inner helper: activate (def --env so PATH change persists)
    let do_activate = { |vname|
        let vpath = ($base | path join $vname)
        if not ($vpath | path exists) {
            error make { msg: $"Virtual environment '($vname)' not found at ($vpath)" }
        }
        # Prepend venv bin to PATH and set VIRTUAL_ENV
        $env.VIRTUAL_ENV = $vpath
        $env.PATH = ($env.PATH | prepend ($vpath | path join "bin"))
        print $"Activated: ($vname) (($vpath))"
    }

    match $action {
        "create" | "c" => {
            if ($name | is-empty) { error make { msg: "Usage: venv create <name>" } }
            do $do_create $name
        }
        "activate" | "a" => {
            if ($name | is-empty) { error make { msg: "Usage: venv activate <name>" } }
            do $do_activate $name
        }
        "deactivate" | "d" => {
            if ($env | get -i VIRTUAL_ENV | is-empty) {
                print "No virtual environment is currently active."
            } else {
                let vbin = ($env.VIRTUAL_ENV | path join "bin")
                $env.PATH = ($env.PATH | where { |p| $p != $vbin })
                $env.VIRTUAL_ENV = ""
                print "Deactivated."
            }
        }
        _ => {
            # Default: treat action as the venv name — create-if-missing then activate
            do $do_create $action
            do $do_activate $action
        }
    }
}


# =============================================================================
# ░░ TERMINAL / WORKSPACE
# =============================================================================

# ─── start-zellij ────────────────────────────────────────────────────────────
# Start Zellij via zellij-runner (if available) or attach to existing session.
# Usage: start-zellij

def start-zellij [] {
    if (^which zellij-runner | complete | get exit_code) == 0 {
        with-env {
            ZELLIJ_RUNNER_LAYOUTS_DIR: ($env.HOME | path join ".config" "zellij" "layouts")
            ZELLIJ_RUNNER_BANNERS_DIR: ($env.HOME | path join ".config" "zellij" "banners")
            ZELLIJ_RUNNER_ROOT_DIR:    ($env.HOME | path join "dev")
        } { ^zellij-runner }
    } else {
        ^zellij attach
    }
}


# ─── diff-so-fancy ───────────────────────────────────────────────────────────
# Pretty-print git diffs. Wraps the Perl script at ~/.bin/diff-so-fancy.
# Typically used as git's core.pager:
#   git config core.pager "diff-so-fancy | less --tabs=4 -RFX"
# Usage: git diff | diff-so-fancy

def diff-so-fancy [...args: string] {
    ^($env.HOME | path join ".bin" "diff-so-fancy") ...$args
}


# =============================================================================
# ░░ SECURITY / UTILITIES
# =============================================================================

# ─── latex ───────────────────────────────────────────────────────────────────
# Run pandoc/latex via Docker, mounting CWD as /data with current user's uid:gid.
# Equivalent to fish: alias latex="docker run --rm --volume $(pwd):/data ..."
# Usage: latex input.md -o output.pdf

def latex [...args: string] {
    if not (^which docker | complete | get exit_code) == 0 {
        error make { msg: "'docker' is not installed" }
    }
    let cwd  = (pwd)
    let uid  = (^id -u | str trim)
    let gid  = (^id -g | str trim)
    ^docker run --rm \
        --volume $"($cwd):/data" \
        --user $"($uid):($gid)" \
        pandoc/latex ...$args
}


# ─── z (zoxide) ──────────────────────────────────────────────────────────────
# Smart directory jump — equivalent to the `z` OMF package.
# Requires: zoxide  (apt install zoxide  or  cargo install zoxide)
#
# Nushell note: `def --env` is required so the `cd` inside persists to the
# calling scope. Without it, changing directory only affects the function scope.
#
# Usage: z foo        jump to the best match for "foo"
#        z foo bar    jump to best match for "foo bar"
#        z -          jump to previous directory

def --env z [...args: string] {
    if not (^which zoxide | complete | get exit_code) == 0 {
        error make { msg: "'zoxide' is not installed. Run: apt install zoxide" }
    }
    let result = (^zoxide query --exclude (pwd) ...$args | str trim)
    if ($result | is-empty) {
        error make { msg: $"zoxide: no match found for '($args | str join ' ')'" }
    }
    cd $result
}

# Zoxide `zi` — interactive selection via fzf
def --env zi [...args: string] {
    if not (^which zoxide | complete | get exit_code) == 0 {
        error make { msg: "'zoxide' is not installed" }
    }
    let result = (^zoxide query --interactive ...$args | str trim)
    if not ($result | is-empty) {
        cd $result
    }
}


# ─── passgen ─────────────────────────────────────────────────────────────────
# Generate a memorable passphrase: 4 random words + a number + punctuation.
# One word is randomly capitalised; separator is randomly . or -.
# Usage: passgen

def passgen [] {
    if not ("/usr/share/dict/words" | path exists) {
        error make { msg: "/usr/share/dict/words not found" }
    }

    let num_words = 4
    let numbers   = [2, 7, 8]
    let puncts    = ["!", "?"]

    # Sample words, strip those with apostrophes, pick 4
    let words = (
        ^shuf -n 100 /usr/share/dict/words
        | lines
        | where { |w| not ($w | str contains "'") }
        | shuffle
        | first $num_words
    )

    if ($words | length) < $num_words {
        error make { msg: "Not enough words sampled from dictionary" }
    }

    # Randomly capitalise one word
    let cap_idx = (random int 0..($num_words - 1))
    let capped  = (
        $words | enumerate | each { |it|
            if $it.index == $cap_idx { $it.item | str upcase } else { $it.item }
        }
    )

    # Random separator, number, punctuation
    let sep    = (["." "-"] | shuffle | first)
    let number = ($numbers | shuffle | first)
    let punct  = ($puncts  | shuffle | first)
    let phrase = ($capped | str join $sep)

    $"($phrase)($sep)($number)($punct)"
}
