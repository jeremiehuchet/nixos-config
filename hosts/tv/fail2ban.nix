{ pkgs, ... }:

let
  secrets = import ../../secrets.nix ;
  freednspassfile = pkgs.writeText "freednspassfile" ''${secrets.freedns.password}'';
in {
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "5m";
    banaction= "iptables-allports";
    bantime-increment = {
      enable = true;
      rndtime = "67s";
      maxtime = "45d";
      # 1m, 5m, 1h, 5h, 12h, 1d, 2d, 4d, 8d
      multipliers = "1 5 30 60 300 720 1440 2880 5760 11520";
      overalljails = true;
    };
    jails = {
      nginx-botsearch = ''
        # block IP address looking like a bot scanner more than 3 times overs 60s
        filter   = nginx-botsearch
        logpath  = /var/log/nginx/access.log
        maxretry = 3
        findtime = 60
      '';
      nginx-bad-request = ''
        # block IP address issuing more than 10 Bad Requests in 5 minutes
        filter   = nginx-bad-request
        logpath  = /var/log/nginx/access.log
        maxretry = 10
        findtime = 300
      '';
    };
  };
}
