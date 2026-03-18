# dotfiles

Personal dotfiles and server setup scripts for Debian-based systems.
Managed with symlinks — no dotfile framework required.

Shell: **fish** + **Oh My Fish** · Editor: **Neovim** (NvChad) · Prompt: **Starship** · Multiplexer: **Zellij / tmux** · Runtime versions: **mise**

---

## Fresh server — one command

> Requires the repo to be public. Run as root or with sudo.

```sh
curl -fsSL https://raw.githubusercontent.com/Zenuncl/.dotfiles/master/setup/bootstrap.sh | sudo bash
```

The bootstrap script will interactively walk you through:

1. Creating a system user (default: `anonymous`, uid `1027`)
2. Cloning this repo into `$HOME/.dotfiles`
3. Updating APT and installing base packages
4. Installing Docker, mise, Neovim
5. Writing a custom sshd config
6. Symlinking dotfiles and scripts
7. Installing Oh My Fish
8. Adding the user to the `docker` group

Every step prompts for confirmation — nothing runs silently.

---

## Repository structure

```
.dotfiles/
├── bin/                        # Personal scripts, symlinked to ~/.bin
│   ├── passgen                 # Password generator
│   ├── ddns                    # Dynamic DNS updater
│   ├── syncfiles               # File sync helper
│   ├── check-*/                # System monitoring scripts
│   └── ...
│
├── config/                     # App configs, symlinked into ~/.config/
│   ├── nvim/                   # Neovim (NvChad-based)
│   ├── omf/                    # Oh My Fish — aliases, env, functions
│   ├── starship/               # Starship prompt config
│   ├── git/                    # Git config, aliases, ignore rules
│   ├── zellij/                 # Zellij terminal multiplexer
│   ├── tmux/                   # tmux config (legacy)
│   ├── alacritty/              # Alacritty terminal
│   ├── hypr/                   # Hyprland WM (wayland)
│   ├── waybar/                 # Waybar status bar (multiple themes)
│   ├── rofi/                   # Rofi launcher and applets
│   ├── mako/                   # Mako notification daemon
│   ├── awesome/                # AwesomeWM config + Skywalker theme
│   └── picom/                  # Picom compositor
│
├── docker/                     # Docker compose files
│
├── setup/                      # System setup scripts
│   ├── bootstrap.sh            # ← Fresh server entry point (run this)
│   │
│   ├── firewall/               # Firewall setup
│   │   ├── firewall.sh         # Interactive nftables + fail2ban setup
│   │   ├── nftables/           # Native nft rule files (loaded by firewall.sh)
│   │   │   ├── 01-general.nft  # Loopback, conntrack, ICMP, SSH
│   │   │   ├── 02-http.nft     # HTTP/HTTPS (TCP + UDP/QUIC)
│   │   │   ├── 03-syncthing.nft
│   │   │   ├── 98-logging.nft  # Rate-limited logging + default drop
│   │   │   └── 99-output.nft   # Allow all outbound
│   │   ├── iptables/           # Legacy iptables rules (reference only)
│   │   └── fail2ban/
│   │       └── jail.local      # fail2ban jail config
│   │
│   ├── install/                # Optional tool installers (run individually)
│   │   ├── aws.sh              # AWS CLI v2 (arch-aware, GPG verified)
│   │   ├── kube.sh             # kubectl (latest stable, checksum verified)
│   │   └── nerdfont.sh         # Nerd Fonts from GitHub releases
│   │
│   └── motd/
│       └── motd                # Message of the day, symlinked to /etc/motd
│
├── ssh/                        # SSH client config
│   └── config
│
└── tmux/                       # tmux local config
```

---

## Symlinks applied by bootstrap

| Symlink | Points to |
|---|---|
| `~/.config/nvim` | `~/.dotfiles/config/nvim` |
| `~/.config/starship` | `~/.dotfiles/config/starship` |
| `~/.config/omf` | `~/.dotfiles/config/omf` |
| `~/.config/git` | `~/.dotfiles/config/git` |
| `~/.bin` | `~/.dotfiles/bin` |
| `/etc/motd` | `~/.dotfiles/setup/motd/motd` |

---

## Firewall setup

After bootstrapping, run the firewall script separately:

```sh
sudo ~/.dotfiles/setup/firewall/firewall.sh
```

Uses native **nftables** (`table inet filter`). Docker's tables (`table ip filter`, `table ip nat`) are never touched. fail2ban is configured with `nftables-allports` banaction.

---

## Optional tool installers

Run any of these independently as root:

```sh
# AWS CLI v2
sudo ~/.dotfiles/setup/install/aws.sh

# kubectl (latest stable)
sudo ~/.dotfiles/setup/install/kube.sh

# Nerd Font (default: JetBrainsMono)
~/.dotfiles/setup/install/nerdfont.sh [FontName]
```

---

## Runtime versions

Language runtimes (Node, Python, Ruby, Go, Rust, etc.) are managed via **[mise](https://mise.jdx.dev/)**, installed by the bootstrap script.

```sh
mise install node@lts
mise install python@latest
mise use --global node@lts
```

---

## SSH config

Custom sshd config is written to `/etc/ssh/sshd_config.d/custom.conf` by bootstrap. Defaults:

- Port `2222`
- `PasswordAuthentication no` globally
- Password login allowed only for the `anonymous` user
- Agent and TCP forwarding enabled

---

## License

MIT
