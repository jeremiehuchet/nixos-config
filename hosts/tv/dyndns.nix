{ pkgs, ... }:

let
  secrets = import ../../secrets.nix ;
  dyndnspassfile = pkgs.writeText "dyndnspassfile" ''${secrets.dyndns.password}'';
in {
  services.ddclient = {
    enable = true;
    ssl = true;
    server = "dns.eu.ovhapis.com";
    protocol = "dyndns2";
    username = secrets.dyndns.username;
    passwordFile = "${dyndnspassfile}";
    domains = [
      secrets.dyndns.domain
    ];
    usev4 = ''
      cmd, cmd='${pkgs.nur.livebox-cli}/bin/livebox-cli --password '${secrets.livebox.password}' --query $.data.IPAddress --raw exec --service NMC --method getWANStatus'
    '';
  };
}
