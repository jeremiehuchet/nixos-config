{ pkgs, ... }:

pkgs.writeScriptBin "nixos" ''
  #!${pkgs.bash}/bin/bash -e

  [[ "$1" == "rebuild" ]] || exit 1
  shift

  PARAMS=""
  UPGRADE=0

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

  cat - <<EOF | sudo -s
  [[ $UPGRADE -gt 0 ]] && nix-channel --update
  nix build '(with import <nixpkgs/nixos> { }; system)'
  nixos-rebuild $PARAMS
  EOF
''
