{ lib, pkgs, config, ... }:

let
  cfg = config.self-hosted.photos;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = { self-hosted.photos.enable = lib.mkEnableOption "Self hosted photos cloud"; };

  config = lib.mkIf cfg.enable {

    services.nginx.virtualHosts."photos.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 5000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };

    services.immich = {
      enable = true;
      package = pkgs.unstable.immich;
      # `null` will give access to all devices.
      accelerationDevices = null;
    };

    # for hardware acceleration
    users.users.immich.extraGroups = [ "video" "render" ];

    services.postgresqlBackup.databases = [ config.services.immich.database.name ];

    services.borgbackup.jobs.immich = {
      startAt = "*-*-* 01:30:00";
      encryption.mode = "none";
      paths = [
        "${config.services.postgresqlBackup.location}/immich.sql.gz"
        "${config.services.immich.mediaLocation}/library"
        "${config.services.immich.mediaLocation}/profile"
        "${config.services.immich.mediaLocation}/upload"
      ];
      repo = "/nas/backup/borg:immich";
      prune.keep = {
        within = "1d";
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };
  };
}
