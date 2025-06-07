{ inputs, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/desktop.nix
  ];

  networking.hostName = "work";

  users.users.workdev = {
    isNormalUser = true;
    description = "Work development user";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.workdev = import ../modules/home.nix { inherit pkgs; };
}
