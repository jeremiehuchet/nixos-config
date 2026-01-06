{ lib, pkgs, config, ... }:

let
  cfg = config.self-hosted.music;
  secrets = import ../secrets.nix;
in {

  options = { self-hosted.music.enable = lib.mkEnableOption "Self hosted music remote player"; };

  config = lib.mkIf cfg.enable {

    services.nginx.virtualHosts."music.huchet.ovh" = {
      forceSSL = true;
      useACMEHost = "huchet.ovh";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };

    services.navidrome = {
      enable = true;
      settings = {
        EnableInsightsCollector = false;
        Agents = "lastfm,deezer";
        Backup = {
          Schedule = "@weekly";
          Count = 7;
        };
        Deezer = {
          Enabled = true;
          Language = "fr";
        };
        DefaultLanguage = "fr";
        LastFM = {
          ApiKey = secrets.lastfm.api-key;
          Secret = secrets.lastfm.secret;
          Language = "fr";
        };
        Scanner.Schedule = "@every 1h";
        LogLevel = "info";
      };
    };

  };
}
