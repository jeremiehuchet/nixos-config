{ lib, pkgs, config, ... }:

let
  cfg = config.smtp-relay;
  secrets = import ../secrets.nix;
in {

  options = { smtp-relay.enable = lib.mkEnableOption "SMTP relay based on msmtp"; };

  config = lib.mkIf cfg.enable {

    environment.etc."msmtp-password".text = secrets.smtp.password;

    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = secrets.smtp.port;
        tls = true;
        tls_starttls = false;
      };
      accounts = {
        default = {
          host = secrets.smtp.host;
          auth = true;
          user = secrets.smtp.username;
          passwordeval = "${pkgs.coreutils}/bin/cat /etc/msmtp-password";
          from = secrets.smtp.username;
        };
      };
    };

  };
}
