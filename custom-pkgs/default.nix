{ pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    devicons-font = pkgs.callPackage ./devicons-font.nix { };
    i3lock-blur = pkgs.callPackage ./i3lock-blur.nix { };
    pretty-nixos-rebuild = pkgs.callPackage ./pretty-nixos-rebuild.nix { };
    zsh-nix-shell = pkgs.callPackage ./zsh-nix-shell.nix { };
  };
}
