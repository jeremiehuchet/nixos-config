{ pkgs, ... }:

let
  secrets = import ../../secrets.nix;
  smtp = secrets.vaultwarden.smtp;
in {
  services.nginx = {
    enable = true;
    virtualHosts."vwar.huchet.ovh" = {
      serverAliases= ["vwar.local.huchet.ovh"];
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };


  services.vaultwarden = {
    enable = true;
    config = {
      LOG_LEVEL = "debug";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      SMTP_HOST = smtp.host;
      SMTP_PORT = smtp.port;
      SMTP_FROM = smtp.from;
      SMTP_SECURITY = smtp.security;
      SMTP_USERNAME = smtp.username;
      SMTP_PASSWORD = smtp.password;
    };
  };
}
