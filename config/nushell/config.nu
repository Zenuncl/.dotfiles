# =============================================================================
# Nushell Main Configuration
# Equivalent to config/omf/init.fish + key_bindings.fish + starship.fish
#
# This file is loaded after env.nu. It sources aliases and commands, sets up
# keybindings, initialises Starship, activates mise, and adds SSH keys.
# =============================================================================

# ─── Source custom modules ───────────────────────────────────────────────────
source ~/.config/nushell/aliases.nu
source ~/.config/nushell/commands.nu

# ─── Nushell behaviour ───────────────────────────────────────────────────────
$env.config = {
    show_banner: false   # equivalent to `set --global fish_greeting ""`

    ls: {
        use_ls_colors: true
        clickable_links: true
    }

    rm: {
        always_trash: false  # set true to send rm'd files to trash instead
    }

    table: {
        mode: rounded
        index_mode: always
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }

    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "sqlite"   # richer history; use "plaintext" if preferred
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
    }

    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }

    # ── Keybindings ───────────────────────────────────────────────────────
    # Equivalent to: bind \cw backward-kill-word  (key_bindings.fish)
    keybindings: [
        {
            name: backward_kill_word
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
        }
        {
            name: history_search
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert]
            event: { send: searchhistory }
        }
        # fzf file picker — equivalent to the `fzf` OMF package (Ctrl+T)
        # Requires: fzf  (apt install fzf)
        {
            name: fzf_file_picker
            modifier: control
            keycode: char_t
            mode: [emacs, vi_insert]
            event: {
                send: executehostcommand
                cmd: "commandline edit --insert (^fzf --height 40% | str trim)"
            }
        }
        # fzf cd picker — jump to directory (Alt+C)
        {
            name: fzf_cd
            modifier: alt
            keycode: char_c
            mode: [emacs, vi_insert]
            event: {
                send: executehostcommand
                cmd: "cd (^find . -type d | ^fzf --height 40% | str trim)"
            }
        }
    ]

    # ── Hooks ─────────────────────────────────────────────────────────────
    hooks: {
        # Run starship prompt update after each command
        pre_prompt: [{ null }]
        pre_execution: [{ null }]
    }
}

# ─── Starship prompt ─────────────────────────────────────────────────────────
# Equivalent to starship.fish — initialise only when starship is available.
if (which starship | is-empty | not $in) {
    # STARSHIP_CONFIG is set in env.nu
    ^starship init nu | save -f /tmp/starship-init.nu
    source /tmp/starship-init.nu
}

# ─── mise (runtime version manager) ─────────────────────────────────────────
# Equivalent to mise.fish — activates mise hooks for the current shell.
# Shims are already on PATH via env.nu; this adds version-switching hooks.
let mise_bin = ($env.HOME | path join ".local" "bin" "mise")
if ($mise_bin | path exists) {
    ^$mise_bin activate nu | save -f /tmp/mise-init.nu
    source /tmp/mise-init.nu
}

# ─── SSH key ─────────────────────────────────────────────────────────────────
# Equivalent to: ssh-add $HOME/.ssh/secrets/keys.sec/github.ed25519.pem
# Runs silently — suppresses output if key is already loaded or agent is absent.
let ssh_key = ($env.HOME | path join ".ssh" "secrets" "keys.sec" "github.ed25519.pem")
if ($ssh_key | path exists) {
    ^ssh-add $ssh_key out+err> /dev/null
}
