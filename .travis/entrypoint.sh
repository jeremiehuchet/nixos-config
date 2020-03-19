#!/bin/sh -e

NIX_RELEASE=$1
CONFIG_PATH=$2

nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixos-$NIX_RELEASE                 nixos
nix-channel --add https://nixos.org/channels/nixos-unstable                     nixos-unstable
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
nix-channel --list
nix-channel --update
nix build --no-link -I nixos-config=/configuration/$CONFIG_PATH '(with import <nixpkgs/nixos> { }; system)'
