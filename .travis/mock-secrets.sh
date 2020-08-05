#!/bin/sh -e

mkdir secrets
touch secrets/m1-ca-1.crt
touch secrets/m1-ca-2.crt
touch secrets/m1-dnsmasq.conf
touch secrets/m1-vpn-cert.p12

cat - <<EOF > secrets.nix
{
  wireless.psk = "secret";
  hosts = {};
  vpn1.remoteIp = "secret";
  m1.homedir = "secret";
  m1.email = "secret";
}
EOF

