{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    unstable = import <nixpkgs-unstable> { };
    nur = import <nur-packages> { };

    battery-alert = pkgs.callPackage ./battery-alert.nix { };
    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    rofi-translate = pkgs.callPackage ./rofi-translate.nix { };
  };
}
