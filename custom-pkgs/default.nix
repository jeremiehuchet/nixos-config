{ pkgs, config, ... }:

{

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: rec {
    unstable = import <nixpkgs-unstable> {
      # propagates "allowUnfree" config
      config = config.nixpkgs.config; };
    nur = import <nur-packages> { inherit pkgs; };

    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    rofi-translate = pkgs.callPackage ./rofi-translate.nix { };
  };
}
