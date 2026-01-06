{ pkgs, ... }:

let
  secrets = import ../../secrets.nix;
in {
  networking.useNetworkd = true;

  networking.firewall.allowedUDPPorts = [ 49154 ];

  systemd.network.wait-online.ignoredInterfaces = [ "home-vpn" ];

  systemd.network = {
    enable = true;
    netdevs = {
      "50-home-vpn" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "home-vpn";
          MTUBytes = "1300";
        };
        wireguardConfig = {
          PrivateKeyFile = "/etc/nixos/secrets/wireguard";
          ListenPort = 49154;
        };
        wireguardPeers = [
          {
            PublicKey = "SZnx4zhYBV+0H1K3Mk0Jnp2+i6Qp3bIYscMmipjuZhw=";
            PresharedKeyFile = "/etc/nixos/secrets/wireguard-presharedkey-op6t";
            AllowedIPs = ["10.0.0.2/32"];
          }
        ];
      };
    };
    networks.home-vpn = {
      matchConfig.Name = "home-vpn";
      address = ["10.0.0.1/24"];
      networkConfig = {
        IPMasquerade = "ipv4";
        IPv4Forwarding = true;
      };
    };
  };
}
