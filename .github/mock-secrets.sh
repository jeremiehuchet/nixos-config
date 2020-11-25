#!/bin/sh -e

mkdir secrets
touch secrets/m0-vpn.p12
touch secrets/m2-ca.crt
touch secrets/m2-proxy.pac
 
cat - <<EOF > secrets.nix
{
  wireless.psk = "secret";
  hosts = {};
  m0.vpn.authUserPass.username = "secret";
  m0.vpn.authUserPass.password = "secret";
  m0.vpn.remoteIpPort = "1.2.3.4 567";
  m2.ssh-gateway.user = "secret";
  m2.ssh-gateway.host = "secret";
  m2.domain = "secret";
  m2.regex-zones = {};
  m2.proxy = "1.2.3.4:567";
}
EOF

