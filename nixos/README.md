# NixOS Quick Start Configuration

This directory contains a basic NixOS flake that references the dotfiles in this repo.
It defines several host configurations for different machines:

- **dev** – personal development machine
- **home** – home desktop
- **server** – server configuration
- **work** – work development machine (uses a separate user `workdev`)

Each host imports common settings from `modules/common.nix` and optional desktop
settings from `modules/desktop.nix`. User dotfiles are linked via
`modules/home.nix` so that your `bin/` and `config/` directories are available
on every machine.

To build a configuration, run for example:

```bash
nix build .#nixosConfigurations.dev.config.system.build.toplevel
```

With the new flake outputs you can also use the shorter syntax:

```bash
nix build .#dev
```

Adjust the `system` attribute in `flake.nix` if your machines use another
architecture.

Hardware-specific settings can be placed in files under `hosts/` named
`hardware-<host>.nix` and imported from each host configuration.
