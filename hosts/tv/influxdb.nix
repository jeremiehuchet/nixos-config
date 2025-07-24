{ pkgs, ... }:

let secrets = import ../../secrets.nix;
in {
  systemd.tmpfiles.rules = [
    "f+ /run/secrets/influxdb--admin-user-password 0600 influxdb2 influxdb2 - ${secrets.influxdb.admin_user_password}"
    "f+ /run/secrets/influxdb--admin-user-token    0600 influxdb2 influxdb2 - ${secrets.influxdb.admin_user_token}"
    "f+ /run/secrets/influxdb--grafana-app-token   0600 influxdb2 influxdb2 - ${secrets.influxdb.grafana_app_token}"
    "f+ /run/secrets/influxdb--hass-app-token      0600 influxdb2 influxdb2 - ${secrets.influxdb.hass_app_token}"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."influxdb.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8086/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };

  services.influxdb2 = {
    enable = true;
    settings = {
      #log-level = "debug";
    };
    provision = {
      enable = true;
      initialSetup = {
        username = "admin";
        organization = "home";
        passwordFile = "/run/secrets/influxdb--admin-user-password";
        tokenFile = "/run/secrets/influxdb--admin-user-token";
        bucket = "main";
      };
      organizations = {
        home = {
          description = "Home";
          buckets.main = {
            description = "Default bucket";
          };
          buckets.hass = {
            description = "Home Assistant bucket";
          };
          buckets.monitoring = {
            description = "Monitoring metrics";
          };
          auths.grafana = {
            readBuckets = ["hass" "monitoring"];
            tokenFile = "/run/secrets/influxdb--grafana-app-token";
          };
          auths.hass = {
            readBuckets = ["hass"];
            writeBuckets = ["hass"];
            tokenFile = "/run/secrets/influxdb--hass-app-token";
          };
        };
      };
    };
  };
}
