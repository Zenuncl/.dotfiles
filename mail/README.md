# Mail

aerc email setup with native IMAP/SMTP, pass, and Glow.

## Quick start

```bash
bash mail/setup.sh                                        # install packages + symlinks
cp accounts/example.conf accounts/personal.conf           # define account
nvim accounts/personal.conf                               # fill in 5–7 fields
pass insert email/personal                                # store password
bash mail/gen.sh                                          # generate accounts.conf
aerc                                                      # launch
```

## Structure

```
mail/
├── accounts/           ← one .conf per account (single source of truth)
│   └── example.conf       template — copy and fill in
├── gen.sh              ← generates aerc/accounts.conf from accounts/*.conf
├── setup.sh            ← one-time: install packages + create symlinks
├── aerc/               → ~/.config/aerc
│   ├── aerc.conf          main config (UI, filters, compose, viewer)
│   ├── binds.conf         vim-style + Gmail keybindings
│   ├── accounts.conf      generated — IMAP source + SMTP outgoing
│   ├── accounts.conf.example  reference for manual setup
│   ├── stylesets/
│   │   └── catppuccin-mocha   Catppuccin Mocha theme (true-color)
│   └── filters/
│       └── ical           ICS calendar invite renderer
└── glow/               → ~/.config/glow
    ├── glow.yml           Glow config
    └── catppuccin-macchiato.json  Glow color theme
```

## Keybindings

### Message list

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `j/k` | navigate | `gi/gs/gd/gt/ga` | go to inbox/sent/drafts/trash/archive |
| `gg/G` | first/last | `J/K` | prev/next folder |
| `l` / `Enter` | open message | `Tab/Shift-Tab` | switch accounts |
| `Ctrl-d/u` | half-page down/up | `O` | check mail |
| `c` | compose | `/` | search (server-side IMAP) |
| `r` | reply | `a` | reply all |
| `f` | forward | `e` | archive |
| `d` | move to trash | `s/S` | flag/unflag |
| `x` | mark/toggle | `Space` | toggle threads |
| `!` | move to spam | `Ctrl-l` | extract URLs |

### Message viewer

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `j/k` | scroll (pager) | `h` | back to list |
| `J/K` | next/prev message | `H` | toggle headers |
| `r` | reply | `a` | reply all |
| `f` | forward | `o` | open attachment |
| `e` | archive | `d` | move to trash |
| `s/S` | flag/unflag | `Ctrl-l` | open link |
| `Ctrl-n/p` | next/prev MIME part | `/` | search in pager |
| `p` | save attachment | `\|` | pipe to command |

### Compose (review)

| Key | Action |
|-----|--------|
| `y` | send |
| `p` | postpone (save draft) |
| `e` | edit |
| `a` | attach file |
| `d` | detach file |
| `q` / `n` | abort |

## Markdown compose

aerc converts markdown to HTML via `[multipart-converters]`.
In compose review mode, run `:multipart text/html` to generate an HTML
version from your markdown body. Requires `pandoc`.

## GPG key fetching

GPG can auto-fetch sender public keys via WKD and keyservers. Add to
`~/.gnupg/gpg.conf`:

```
auto-key-locate wkd,keyserver
keyserver hkps://keys.openpgp.org
auto-key-retrieve
```

### Per-account PGP in aerc

Add to the account section in `accounts.conf` (or `accounts/*.conf` + re-run gen.sh):

```ini
pgp-auto-sign = true
pgp-self-encrypt = true
pgp-key-id = YOUR_KEY_ID
```

In aerc compose, use `:sign` and `:encrypt` commands.

## Filters

| MIME type | Handler |
|-----------|---------|
| `text/html` | lynx (inline rendering) |
| `text/calendar`, `application/ics` | built-in ICS renderer |
| `text/markdown` | glow (Catppuccin theme) |
| `text/x-diff`, `text/x-patch` | delta (colorized) |
