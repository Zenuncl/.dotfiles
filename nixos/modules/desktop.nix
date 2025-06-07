{ config, pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.desktopManager = {
    xterm.enable = false;
  };
  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    rofi
    waybar
    mako
    grim slurp swappy
    cliphist
    copyq
    wl-clipboard
    xclip
    nerdfonts
  ];
}
