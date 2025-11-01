{ config, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  # Use zsh as default shell
  users.defaultUserShell = pkgs.zsh;

  # Basic packages shared across machines
  environment.systemPackages = with pkgs; [
    git
    neovim
    tmux
    fzf
    ripgrep
    fd
    wget
    curl
    starship
    htop
  ];

  programs.zsh.enable = true;
  programs.tmux.enable = true;
  programs.ssh.startAgent = true;
  virtualisation.docker.enable = true;
  services.tailscale.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
