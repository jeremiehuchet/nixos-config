{ lib, pkgs, config, ... }:

let
  cfg = config.self-hosted.workspace;
  secrets = import ../secrets.nix;
  dbpassFile = pkgs.writeText "nextcloud-dbpass-file" secrets.nextcloud.database-password;
in {

  options = { self-hosted.workspace.enable = lib.mkEnableOption "Self hosted workspace cloud"; };

  config = lib.mkIf cfg.enable {

    environment.etc."nextcloud-admin-pass".text = secrets.nextcloud.admin-password;

    services.nginx.virtualHosts."workspace.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud32;
      hostName = "workspace.huchet.ovh";
      https = true;
      config = {
        adminpassFile = "/etc/nextcloud-admin-pass";
        dbpassFile = toString dbpassFile;
        dbtype = "pgsql";
      };
      settings = {
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\MSOffice2003"
          "OC\\Preview\\MSOffice2007"
          "OC\\Preview\\MSOfficeDoc"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\PDF"
          "OC\\Preview\\SVG"
        ];
        mail_domain = "nextcloud@noreply.huchet.ovh";
        mail_sendmailmode = "pipe";
      };
    };

    services.postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
      ];
    };

  };
}
