{ config, lib, pkgs, ... }:

let
  cfg = config.custom.m0;
  secrets = import ../../secrets.nix;
  secretFiles = ../../secrets;
in {
  options = { custom.m0.enable = lib.mkEnableOption "M0 tools"; };

  config = lib.mkIf cfg.enable {

    services.openvpn.servers.vpn0 = {
      authUserPass = secrets.vpn0.authUserPass;
      config = ''
        client
        dev tun
        proto udp
        remote ${secrets.vpn0.remoteIp}
        pkcs12 ${secretFiles}/m0-vpn-cert.p12
        cipher AES-256-CBC
        auth-user-pass
        auth-nocache
      '';
    };

  };
}
