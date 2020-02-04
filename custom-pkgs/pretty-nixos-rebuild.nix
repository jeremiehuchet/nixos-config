{ pkgs, ... }:

pkgs.writeScriptBin "nixos" ''
  #!${pkgs.bash}/bin/bash -e
  sudo -s echo -n ""
  PARAMS=""
  UPGRADE=0
  [[ "$1" == ""rebuild ]] || exit 1
  shift
  while (( "$#" )); do
    case "$1" in
      --upgrade)
        UPGRADE=1
        shift
        ;;
      *)
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
  done
  [[ $UPGRADE -gt 0 ]] && nix-channel --update
  nix build '(with import <nixpkgs/nixos> { }; system)'
  sudo nixos-rebuild $PARAMS
''
