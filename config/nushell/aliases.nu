# =============================================================================
# Nushell Aliases
# Equivalent to config/omf/custom/alias.fish
#
# Notes:
#   - Use ^cmd (caret) to explicitly call an external binary, bypassing
#     Nushell builtins (e.g. ^ls forces GNU ls instead of nu's built-in ls).
#   - Aliases that need arguments are defined as `def` commands in commands.nu.
#   - Nushell's built-in `ls`, `ps`, `df` etc. are powerful and structured;
#     the aliases below preserve the familiar GNU behaviour where needed.
# =============================================================================

# ─── Shell ───────────────────────────────────────────────────────────────────
alias c = clear
alias x = exit
# Note: `h` is defined as a def in commands.nu — aliases cannot contain pipes

# ─── Time zones ──────────────────────────────────────────────────────────────
alias utc_time = TZ='Etc/UTC' date
alias nyc_time = TZ='Canada/Eastern' date
alias sha_time = TZ='Asia/Shanghai' date
alias par_time = TZ='Europe/Paris' date
alias tyo_time = TZ='Asia/Tokyo' date

# ─── File listing ────────────────────────────────────────────────────────────
# Uses external GNU ls; Nushell's built-in `ls` is available without alias
alias ls = ^ls -all --human-readable --color=auto
alias ll = ^ls -l --human-readable --color=auto
alias la = ^ls -l --all --human-readable --color=auto

# ─── File operations ─────────────────────────────────────────────────────────
alias cp    = ^cp --interactive
alias mv    = ^mv --interactive
alias rm    = ^rm --interactive
alias mkdir = ^mkdir --parents
alias du    = ^du --human-readable
alias df    = ^df --human-readable

# ─── Text / search ───────────────────────────────────────────────────────────
alias less  = ^less --raw-control-chars
alias grep  = ^grep --color=auto
alias ff    = ^find . -type f -name   # fast find:  ff "*.rs"
alias cat   = ^bat --theme=ansi

# ─── System monitoring ───────────────────────────────────────────────────────
alias top   = ^htop
alias t     = ^htop
alias free  = ^free --human
alias ps    = ^ps auxf

# ─── History helpers ─────────────────────────────────────────────────────────
# Note: `hc`, `hg`, `ag` use Nushell pipeline idioms instead of grep
# hc  → history | where command contains "…"
# hg  → same as hc
# ag  → aliases | where name contains "…"
# These are defined as commands in commands.nu for argument support.

# ─── Navigation ──────────────────────────────────────────────────────────────
# Nushell has built-in `cd` — pushd/popd equivalents via `enter`/`exit`/`shells`
alias pud = enter    # push directory (Nushell multi-shell)
alias ppd = exit     # pop directory

# ─── Editors ─────────────────────────────────────────────────────────────────
alias vi   = ^nvim
alias vim  = ^nvim
alias nvi  = ^nvim
alias mutt = ^neomutt

# ─── Network / web ───────────────────────────────────────────────────────────
alias weather = ^curl wttr.in
alias ipinfo  = ^curl ipinfo.io

# ─── Archive extraction ───────────────────────────────────────────────────────
# Simple wrappers — single-arg aliases that delegate to tar/unzip
alias gz  = ^tar -xzvf
alias tgz = ^tar -xzvf
alias bz2 = ^tar -xjvf
alias zip = ^unzip          # mirrors fish: alias zip='unzip'

# ─── Java ────────────────────────────────────────────────────────────────────
alias javac = ^javac -J-Dfile.encoding=utf8

# ─── Misc ────────────────────────────────────────────────────────────────────
alias zj   = start-zellij
alias wiki = ^minori
alias which = ^which
