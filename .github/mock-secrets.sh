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
  dyndns.username = "secret";
  dyndns.password = "secret";
  dyndns.domain = "secret";
  livebox.password = "secret";
  acme.contactEmail = "secret";
  acme.dnsProvider = "secret";
  acme.credentials."huchet.ovh" = "secret";
  home-automation = {
    winky-password = "secret";
    rika-username = "secret";
    rika-password = "secret";
    somfy-username = "secret";
    somfy-password = "secret";
    somfy-client-id = "secret";
    somfy-client-secret = "secret";
    fuel-stations = [];
    zigbee.network_key = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
  };
  home-vpn = {
    username = "secret";
    password = "secret";
  };
  vaultwarden.email = "secret";
  vaultwarden.smtp = {
    host = "secret";
    port = 444;
    from = "secret";
    security = "secret";
    password = "secret";
    username = "secret";
  };
  influxdb = {
    admin_user_password = "secret";
    admin_user_token = "secret";
    grafana_app_token = "secret";
    hass_app_token = "secret";
  };
}
EOF

