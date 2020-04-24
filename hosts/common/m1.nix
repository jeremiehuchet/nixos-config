{ config, lib, pkgs, ... }:

let
  cfg = config.custom.m1;
  secrets = import ../../secrets.nix;
  secretFiles = ../../secrets;
in {

  options = { custom.m1.enable = lib.mkEnableOption "M1 tools"; };

  config = lib.mkIf cfg.enable {

    security.pki.certificates = [ (builtins.readFile ../../secrets/m1-ca.crt) ];

    environment.etc."NetworkManager/dnsmasq.d/m1-dns-servers.conf".source = "${secretFiles}/m1-dnsmasq.conf";

    services.openvpn.servers.vpn1 = {
      config = ''
        client
        dev tun
        remote ${secrets.vpn1.remoteIp}
        pkcs12 ${secretFiles}/m1-vpn-cert.p12
        cipher AES-256-CBC
        lport 1195
        pull
      '';
    };

  };
}
