# Mail

aerc email setup with native IMAP/SMTP and pass.

## Quick start

```bash
bash mail/setup.sh                                        # install packages + symlinks
cp accounts/example.conf accounts/personal.conf           # define account
nvim accounts/personal.conf                               # fill in 5–7 fields
pass insert email/personal                                # store password
bash mail/gen.sh                                          # generate accounts.conf
aerc                                                      # launch
```

## OAuth accounts (Gmail, Outlook)

aerc has built-in OAuth2 support — no third-party tools needed. Refresh
tokens are stored in `pass`, same as regular passwords.

```bash
cp accounts/example.conf accounts/gmail.conf
nvim accounts/gmail.conf                       # set AUTH=google-oauth, CLIENT_ID, etc.
bash oauth.sh accounts/gmail.conf              # device-code flow (headless OK)
# → open the URL on any device, enter the code
# → refresh token saved to pass automatically
bash gen.sh                                    # regenerate accounts.conf
aerc
```

**Google**: create a GCP project → APIs & Services → Credentials → OAuth 2.0
Client ID (type: TVs and Limited Input devices). Set app to "In production"
for non-expiring refresh tokens.

**Microsoft**: create an Azure app → Authentication → Allow public client
flows = Yes → API permissions: IMAP.AccessAsUser.All, SMTP.Send, offline_access.
Or use Thunderbird's public client_id: `9e5f94bc-e8a4-4e73-b8be-63364c29d753`.

**Protonmail**: requires protonmail-bridge running locally. Use TYPE=generic
with IMAP_HOST=127.0.0.1, IMAP_PORT=1143, SMTP_HOST=127.0.0.1, SMTP_PORT=1025,
and the bridge-generated password in `pass`.

## Structure

```
mail/
├── accounts/           ← one .conf per account (single source of truth)
│   └── example.conf       template — copy and fill in
├── gen.sh              ← generates aerc/accounts.conf from accounts/*.conf
├── oauth.sh            ← one-time: device-code OAuth2 flow → stores token in pass
├── setup.sh            ← one-time: install packages + create symlinks
└── aerc/               → ~/.config/aerc
    ├── aerc.conf          main config (UI, filters, compose, viewer)
    ├── binds.conf         vim-style + Gmail keybindings
    ├── accounts.conf      generated — IMAP source + SMTP outgoing
    ├── accounts.conf.example  reference for manual setup
    ├── stylesets/
    │   └── catppuccin-mocha   Catppuccin Mocha theme (true-color)
    └── filters/
        └── ical           ICS calendar invite renderer
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
| `text/markdown` | pandoc → lynx (markdown → HTML → rendered text) |
| `text/calendar`, `application/ics` | built-in ICS renderer |
| `text/x-diff`, `text/x-patch` | delta (colorized) |
