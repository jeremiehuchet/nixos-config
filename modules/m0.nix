{ lib, pkgs, config, ... }:

let
  cfg = config.custom.m0;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = { custom.m0.enable = lib.mkEnableOption "M0 tools"; };

  config = {

    services.openvpn.servers.m0 = {
      authUserPass = secrets.m0.vpn.authUserPass;
      config = ''
        client
        dev tun
        proto udp
        remote ${secrets.m0.vpn.remoteIpPort}
        pkcs12 ${secretFiles}/m0-vpn.p12
        auth-user-pass
        auth-nocache
        cipher AES-256-CBC
      '';
    };

  };
}
