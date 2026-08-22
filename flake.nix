{
  description = "NixOS configuration for my hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages.url = "github:jeremiehuchet/nur-packages";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, nur-packages, ... }@inputs:
    let
      mkHost = { hostModule, extraModules ? [ ] }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            home-manager.nixosModules.home-manager
          ] ++ extraModules;
        };
    in {
      nixosConfigurations = {
        tv = mkHost { hostModule = ./hosts/tv.nix; };
        laptop = mkHost {
          hostModule = ./hosts/laptop.nix;
          extraModules = [
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
          ];
        };
      };
    };
}
