# =============================================================================
# Nushell Environment Configuration
# Equivalent to config/omf/custom/env.fish
#
# Loaded by Nushell before config.nu — environment variables and PATH only.
# No commands, aliases, or sourcing of other files here.
# =============================================================================

# ─── Locale ──────────────────────────────────────────────────────────────────
$env.LC_ALL   = "en_US.UTF-8"
$env.LANG     = "en_US.UTF-8"
$env.LC_CTYPE = "en_US.UTF-8"

# ─── Core ────────────────────────────────────────────────────────────────────
$env.EDITOR   = "/usr/bin/nvim"
$env.VISUAL   = "/usr/bin/nvim"

# ─── Workspace paths ─────────────────────────────────────────────────────────
$env.DOTFILES  = ($env.HOME | path join ".dotfiles")
$env.WORKSPACE = ($env.HOME | path join "dev")
$env.PROJECT   = ($env.HOME | path join "dev" "projects")
$env.GOPATH    = ($env.HOME | path join "dev" "go")

# ─── Starship ────────────────────────────────────────────────────────────────
$env.STARSHIP_CONFIG = ($env.HOME | path join ".config" "starship" "starship.toml")

# ─── PATH ────────────────────────────────────────────────────────────────────
# Nushell PATH is a list — prepend custom dirs so they take priority
$env.PATH = (
    $env.PATH
    | prepend [
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/bin"
        "/usr/sbin"
        "/bin"
        "/sbin"
        ($env.HOME | path join ".local" "bin")
        ($env.HOME | path join ".bin")
        ($env.GOPATH | path join "bin")
    ]
    | uniq   # remove duplicates that may accumulate on re-source
)

# ─── mise shims (runtime version manager) ────────────────────────────────────
# Prepend mise shims so managed runtimes (node, python, go…) are found first.
# Full activation (hooks) is handled in config.nu via `mise activate nu`.
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local" "share" "mise" "shims"))

# ─── Load secrets from ~/.secrets/.env ───────────────────────────────────────
# Reads KEY=VALUE pairs, skips blank lines and comments (#).
# Variables may reference $HOME — literal expansion only (no subshell eval).
let secrets_file = ($env.HOME | path join ".secrets" ".env")
if ($secrets_file | path exists) {
    let env_map = (
        open $secrets_file
        | lines
        | where { |line|
            let t = ($line | str trim)
            ($t | str length) > 0 and not ($t | str starts-with '#')
        }
        | each { |line|
            # Split on first '=' only, preserving values that contain '='
            let parts = ($line | split row -n 2 '=')
            if ($parts | length) == 2 {
                { key: ($parts | first | str trim), val: ($parts | last | str trim) }
            }
        }
        | compact
        | reduce --fold {} { |item, acc| $acc | insert $item.key $item.val }
    )
    load-env $env_map
}
