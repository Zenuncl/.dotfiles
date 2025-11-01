{
  description = "Quick start NixOS config from dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      lib = nixpkgs.lib;
      inherit (nixpkgs) pkgs;
    in
    {
      formatter.x86_64-linux = pkgs.nixpkgs-fmt;
      nixosConfigurations = {
        dev = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/dev.nix
            home-manager.nixosModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };

        home = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/home.nix
            home-manager.nixosModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };

        server = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/server.nix
            home-manager.nixosModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };

        work = lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/work.nix
            home-manager.nixosModules.home-manager
          ];
          specialArgs = { inherit inputs; };
        };
      };

      packages.x86_64-linux = let cfgs = self.nixosConfigurations; in {
        dev = cfgs.dev.config.system.build.toplevel;
        home = cfgs.home.config.system.build.toplevel;
        server = cfgs.server.config.system.build.toplevel;
        work = cfgs.work.config.system.build.toplevel;
      };
    };
}
