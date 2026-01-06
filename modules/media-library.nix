{ lib, pkgs, config, ... }:

let
  cfg = config.media-library;
  secrets = import ../secrets.nix;
  mediaServices = {
    prowlarr = config.services.prowlarr.settings.server.port;
    sonarr = config.services.sonarr.settings.server.port;
    radarr = config.services.radarr.settings.server.port;
    bazarr = config.services.bazarr.listenPort;
    qbittorrent = 9091;
  };
in {

  options = { media-library.enable = lib.mkEnableOption "Media library tools"; };

  config = lib.mkIf cfg.enable {

    services.nginx.virtualHosts = builtins.mapAttrs (name: port: {
      serverAliases = [ "${name}.lan" ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          allow 127.0.0.1;
          allow 192.168.2.0/24;
          allow 10.0.0.2/32;
          deny all;
        '';
      };
    }) mediaServices;

    services.qbittorrent = {
      enable = true;
      webuiPort = 9091;
      serverConfig = {
        Preferences = {
          WebUI = {
            Username = secrets.qbittorrent.username;
            Password_PBKDF2 = secrets.qbittorrent.password;
          };
        };
      };
    };

    systemd.services.qbittorrent = {
      after = ["gluetun.service"];
      requires = ["gluetun.service"];
      serviceConfig = {
        NetworkNamespacePath = "/run/netns/gluetun";
        PrivateNetwork = lib.mkForce true;
      };
    };

    services.prowlarr.enable = true;

    services.sonarr.enable = true;

    services.radarr.enable = true;

    services.bazarr.enable = true;

  };
}
