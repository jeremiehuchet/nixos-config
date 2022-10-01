#!/usr/bin/env bash

NIX_PATH=$(
  nix --extra-experimental-features nix-command \
      eval --impure --expr '(builtins.concatStringsSep ":" (import ./pinned-channels).nixPath)' \
      | sed 's/^"//g' | sed 's/"$//g'
)
echo $NIX_PATH
export NIX_PATH

nixos-rebuild "$@"
