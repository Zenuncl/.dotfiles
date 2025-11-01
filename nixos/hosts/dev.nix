{ inputs, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
    ../modules/desktop.nix
  ];

  networking.hostName = "dev";

  users.users.coder = {
    isNormalUser = true;
    description = "Personal development user";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager.users.coder = import ../modules/home.nix { inherit pkgs; };
}
