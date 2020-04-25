#!/bin/sh -e

NIX_RELEASE=$1
CONFIG_PATH=$2

mkdir -p /configuration/secrets
touch \
    /configuration/secrets/m0-vpn-cert.p12 \
    /configuration/secrets/m1-ca-1.crt \
    /configuration/secrets/m1-ca-2.crt \
    /configuration/secrets/m1-dnsmasq.conf \
    /configuration/secrets/m1-vpn-cert.p12

cat - <<EOF > /configuration/secrets.nix
{
  wireless.psk = "secret";
  hosts = {};
  vpn0.remoteIp = "secret";
  vpn0.authUserPass.username = "secret";
  vpn0.authUserPass.password = "secret";
  vpn1.remoteIp = "secret";
}
EOF
nix-channel --remove nixpkgs
nix-channel --add https://nixos.org/channels/nixos-$NIX_RELEASE nixpkgs
nix-channel --add https://nixos.org/channels/nixpkgs-unstable   nixpkgs-unstable
nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
nix-channel --add https://github.com/jeremiehuchet/nur-packages/archive/master.tar.gz nur-packages
nix-channel --list
nix-channel --update
NIXPKGS_ALLOW_UNFREE=1 nix build --no-link -I nixos-config=/configuration/$CONFIG_PATH '(with import <nixpkgs/nixos> { }; system)'
