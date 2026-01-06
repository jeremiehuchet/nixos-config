{ lib, pkgs, config, ... }:

let
  cfg = config.vpn-gateway;
  secrets = import ../secrets.nix;
in {

  options = with lib; {
    vpn-gateway = {
      enable = mkEnableOption "Proxy to route trafic through VPN.";
      isolatedServices = mkOption {
        description = "Defines the systemd services that should be isolated in gluetun network namespace";
        type = types.attrsOf (types.listOf types.str);
        default = {};
        example = {
          microsocks = [ "127.0.0.1:1080:1080/tcp" ];
          bittornado = [ "9091:9091/tcp" ];
        };
      };
    };
  };

  config = let
    isolatedPorts = [ "127.0.0.1:1080:1080/tcp" ] ++ lib.concatLists (builtins.attrValues cfg.isolatedServices);
    isolatedServicesNames = [ "microsocks" ] ++ builtins.attrNames cfg.isolatedServices;
  in lib.mkIf cfg.enable {

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers.containers."gluetun" = {
      serviceName = "gluetun";
      image = "qmcgaw/gluetun:v3";
      pull = "newer";
      ports = isolatedPorts;
      environment = {
        VPN_SERVICE_PROVIDER = secrets.privacy-vpn.provider;
        VPN_TYPE = "openvpn";
        OPENVPN_USER = secrets.privacy-vpn.username;
        OPENVPN_PASSWORD = secrets.privacy-vpn.password;
        SERVER_COUNTRIES = secrets.privacy-vpn.countries;
        DNS_UPSTREAM_RESOLVERS = "cloudflare,google,libredns";
        UPDATER = "24h";
      };
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };
      devices = [ "/dev/net/tun:/dev/net/tun" ];
      volumes = [ "/etc/nixos/secrets/openvpn:/gluetun:ro" ];
    };

    services.microsocks.enable = true;
    services.microsocks.ip = "*";

    systemd.services = {
      gluetun = {
        postStart = ''
          PID=$(${pkgs.podman}/bin/podman inspect -f '{{.State.Pid}}' gluetun)
          mkdir -p /run/netns
          ln -sfT /proc/$PID/ns/net /run/netns/gluetun
        '';
        preStop = ''
          rm -f /run/netns/gluetun
        '';
      };
    } // (lib.genAttrs isolatedServicesNames (name: {
        after = ["gluetun.service"];
        requires = ["gluetun.service"];
        serviceConfig = {
          NetworkNamespacePath = "/run/netns/gluetun";
          PrivateNetwork = lib.mkForce true;
        };
    }));
  };
}
