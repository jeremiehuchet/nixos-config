#!/usr/bin/env bash

NIX_PATH=$(
  cd /etc/nixos
  nix --extra-experimental-features nix-command \
      eval --impure --expr '(import ./pinned-channels).nixPathString' \
      | sed 's/^"//g' | sed 's/"$//g'
)
echo $NIX_PATH
export NIX_PATH

nixos-rebuild "$@"
