{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    pyrandr = pkgs.callPackage ./pyrandr.nix { };
    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    zsh-nix-shell = pkgs.callPackage ./zsh-nix-shell.nix { };
  };
}
