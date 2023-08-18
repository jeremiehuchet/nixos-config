{ pkgs, ... }:

let
  secrets = import ../../secrets.nix ;
  freednspassfile = pkgs.writeText "freednspassfile" ''${secrets.freedns.password}'';
in {
  services.ddclient = {
    enable = true;
    ssl = true;
    server = "freedns.afraid.org";
    protocol = "freedns";
    username = secrets.freedns.username;
    passwordFile = "${freednspassfile}";
    domains = [
      "hass.ignorelist.com"
    ];
    use = ''
      cmd, cmd='${pkgs.nur.livebox-cli}/bin/livebox-cli --password '${secrets.livebox.password}' --query $.data.IPAddress --raw exec --service NMC --method getWANStatus'
    '';
  };
}
