{ inputs, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/desktop.nix
  ];

  networking.hostName = "home";

  users.users.coder = {
    isNormalUser = true;
    description = "Home user";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.coder = import ../modules/home.nix { inherit pkgs; };
}
