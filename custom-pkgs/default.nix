{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    battery-alert = pkgs.callPackage ./battery-alert.nix { };
    bazarr = pkgs.callPackage ./bazarr.nix { };
    now-cli = pkgs.callPackage ./now-cli.nix { };
    pyrandr = pkgs.callPackage ./pyrandr.nix { };
    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    rofimoji = pkgs.callPackage ./rofimoji.nix { };
  };
}
