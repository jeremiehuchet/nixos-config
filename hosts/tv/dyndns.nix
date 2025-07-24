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
    # not updateing ipv4 and ipv6 at the same time because it fails
    # SENDING:  url="https://dns.eu.ovhapis.com/nic/update?system=dyndns&hostname=host.domain.tld&myip=136.101.43.163,a3ce:174b:2cca:2fc3:4d13:a092:05c7:4937&wildcard=ON"
    # RECEIVE:  HTTP/1.1 400 Bad Request
    # RECEIVE:  {"class":"Client::BadRequest","message":"{'myip': ['Invalid ip']}"}
    #usev6 = "cmdv6, cmdv6=${showIpv6}/bin/ip-addr-show-v6";
    usev6 = "";
    #verbose = true;
  };
}
