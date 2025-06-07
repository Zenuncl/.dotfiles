{ inputs, pkgs, ... }:
{
  imports = [
    ../modules/common.nix
  ];

  networking.hostName = "server";
  services.openssh.enable = true;

  users.users.coder = {
    isNormalUser = true;
    description = "Server admin";
    extraGroups = [ "wheel" ];
  };

  home-manager.users.coder = import ../modules/home.nix { inherit pkgs; };
}
