#!/bin/sh -e

mkdir secrets
touch secrets/m0-vpn.p12
touch secrets/m2-ca.crt
touch secrets/m2-proxy.pac
 
cat - <<EOF > secrets.nix
{
  email = "secret";
  wireless.psk = "secret";
  home.longitude = 1.1234567;
  home.latitude = 1.21234567;
  hass.prometheus-token = "secret";
  freedns.username = "secret";
  freedns.password = "secret";
  livebox.password = "secret";
  home-automation = {
    winky-password = "secret";
    rika-username = "secret";
    rika-password = "secret";
    somfy-username = "secret";
    somfy-password = "secret";
    somfy-client-id = "secret";
    somfy-client-secret = "secret";
  };
}
EOF

