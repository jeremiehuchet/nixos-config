#!/usr/bin/env bash

NIX_PATH=$(nix eval --raw '(builtins.concatStringsSep ":" (import ./pinned-channels).nixPath)')
export NIX_PATH

nixos-rebuild "$@"
