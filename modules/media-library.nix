{ lib, pkgs, config, ... }:

let
  cfg = config.media-library;
  secrets = import ../secrets.nix;
in {

  options = { media-library.enable = lib.mkEnableOption "Media library tools"; };

  config = lib.mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [ 9091 ];

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

  };
}
