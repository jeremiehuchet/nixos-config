{ pkgs, ... }:

let secrets = import ../../secrets.nix;
in {
  systemd.tmpfiles.rules = [
    "f+ /run/secrets/grafana--admin-password 0600 grafana grafana - ${secrets.grafana.admin_password}"
    "f+ /run/secrets/grafana--influxbd-access-token 0600 grafana grafana - ${secrets.influxdb.grafana_app_token}"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."grafana.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };


  services.grafana = {
    enable = true;
    settings = {
      analytics.reporting_enabled = false;
      security = {
        disable_gravatar = true;
        cookie_secure = true;
        admin_user = "admin";
        admin_password = "$__file{/run/secrets/grafana--admin-password}";
        admin_email = secrets.email;
      };
      server = {
        enforce_domain = true;
        domain = "grafana.huchet.ovh";
        enable_gzip = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "influxdb";
          type = "influxdb";
          uid = "influxdb";
          access = "proxy";
          url = "http://127.0.0.1:8086";
          secureJsonData = {
            token = "$__file{/run/secrets/grafana--influxbd-access-token}";
          };
          jsonData = {
            version = "Flux";
            organization = "home";
          };
          editable = false;
        }
      ];
    };
  };
}
