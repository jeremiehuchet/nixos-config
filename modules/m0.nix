{ lib, pkgs, config, ... }:

let
  cfg = config.custom.m0;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = { custom.m0.enable = lib.mkEnableOption "M0 tools"; };

  config = lib.mkIf cfg.enable {

    services.openvpn.servers.m0 = {
      authUserPass = {
        username = secrets.m0.vpn.username;
        password = secrets.m0.vpn.password;
      };
      config = ''
        client
        dev tun
        proto udp
        remote ${secrets.m0.vpn.remoteIpPort}
        pkcs12 ${secretFiles}/m0-vpn.p12
        auth-user-pass
        auth-nocache
        cipher AES-256-CBC
        route-nopull
        route ${secrets.m2.ssh-gateway.host} 255.255.255.255
      '';
    };

  };
}
