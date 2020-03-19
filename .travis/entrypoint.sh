#!/bin/sh

echo $0 $*

exec nix build --no-link -I nixos-config=/configuration/$1 '(with import <nixpkgs/nixos> { }; system)'
