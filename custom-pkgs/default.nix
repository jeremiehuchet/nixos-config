{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    unstable = import <nixpkgs-unstable> { };
    nur = import <nur-packages> { };

    battery-alert = pkgs.callPackage ./battery-alert.nix { };
    bazarr = pkgs.callPackage ./bazarr.nix { };
    devicons = pkgs.callPackage ./devicons.nix { };
    pyrandr = pkgs.callPackage ./pyrandr.nix { };
    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    rofi-translate = pkgs.callPackage ./rofi-translate.nix { };
    rofimoji = pkgs.callPackage ./rofimoji.nix { };
  };
}
