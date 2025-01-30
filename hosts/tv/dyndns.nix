{ pkgs, ... }:

let
  secrets = import ../../secrets.nix ;
  dyndnspassfile = pkgs.writeText "dyndnspassfile" ''${secrets.dyndns.password}'';
  showIpv4 = pkgs.writeScriptBin "ip-addr-show-v4" "${pkgs.nur.livebox-cli}/bin/livebox-cli --password '${secrets.livebox.password}' --query $.data.IPAddress --raw exec --service NMC --method getWANStatus";
  showIpv6 = pkgs.writeScriptBin "ip-addr-show-v6" "${pkgs.nur.livebox-cli}/bin/livebox-cli --password '${secrets.livebox.password}' --query $.data.IPv6Address --raw exec --service NMC --method getWANStatus";
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
    usev4 = "cmdv4, cmdv4=${showIpv4}/bin/ip-addr-show-v4";
    usev6 = "cmdv6, cmdv6=${showIpv6}/bin/ip-addr-show-v6";
  };
}
