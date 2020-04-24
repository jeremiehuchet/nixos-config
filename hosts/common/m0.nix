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
        remote ${secrets.vpn0.remoteIp} 1194
        pkcs12 ${secretFiles}/vpn0.p12
        auth-user-pass
        auth-nocache
        cipher AES-256-CBC
      '';
    };

  };
}
