#!/bin/sh -e

mkdir secrets
touch secrets/m2-proxy.pac

cat - <<EOF > secrets.nix
{
  wireless.psk = "secret";
  hosts = {};
  m2.proxy = "secret";
}
EOF

