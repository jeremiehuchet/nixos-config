{ lib, pkgs, config, ... }:

let
  cfg = config.vpn-gateway;
  secrets = import ../secrets.nix;
in {

  options = { vpn-gateway.enable = lib.mkEnableOption "Proxy to route trafic through VPN"; };

  config = lib.mkIf cfg.enable {

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers.containers."gluetun" = {
      serviceName = "gluetun";
      image = "qmcgaw/gluetun:v3";
      pull = "newer";
      ports = [
        "8388:8388/tcp"
        "9091:9091/tcp"
      ];
      environment = {
        VPN_SERVICE_PROVIDER = secrets.privacy-vpn.provider;
        VPN_TYPE = "openvpn";
        OPENVPN_USER = secrets.privacy-vpn.username;
        OPENVPN_PASSWORD = secrets.privacy-vpn.password;
        SERVER_COUNTRIES = secrets.privacy-vpn.countries;
        DNS_UPSTREAM_RESOLVERS = "cloudflare,google,libredns";
        BLOCK_SURVEILLANCE = "on";
        BLOCK_ADS = "on";
        SHADOWSOCKS = "on";
        SHADOWSOCKS_CIPHER = "AES-128-GCM";
        SHADOWSOCKS_PASSWORD="trusted";
        UPDATER = "24h";
      };
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      volumes = [ "/etc/nixos/secrets/openvpn:/gluetun:ro" ];
    };

    systemd.services."gluetun" = {
      postStart = ''
        PID=$(${pkgs.podman}/bin/podman inspect -f '{{.State.Pid}}' gluetun)
        mkdir -p /run/netns
        ln -sfT /proc/$PID/ns/net /run/netns/gluetun
      '';
      preStop = ''
        rm -f /run/netns/gluetun
      '';
    };

    systemd.services.socks5-private = {
      enable = true;
      description = "A socks5 proxy for private browsing";
      after = [ "podman-gluetun.service" ];
      wants = [ "podman-gluetun.service" ];
      script = "${pkgs.shadowsocks-rust}/bin/sslocal -b 127.0.0.1:1080 -s 127.0.0.1:8388 -m aes-128-gcm -k trusted";
    };

  };
}
