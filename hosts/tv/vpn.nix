{ pkgs, ... }:

let
  secrets = import ../../secrets.nix;
in {
  networking.firewall.allowedUDPPorts = [ 49154 ];
  networking.nat.enable = true;
  networking.nat.externalInterface = "wireless";
  networking.nat.internalInterfaces = [ "vpn" ];

  networking.wireguard.interfaces = {
    vpn = {
      ips = [ "10.0.0.1/24" ];
      listenPort = 49154;
      privateKeyFile = "/etc/nixos/secrets/wireguard";
      peers = [
        { # OP6T
          publicKey = "SZnx4zhYBV+0H1K3Mk0Jnp2+i6Qp3bIYscMmipjuZhw=";
          presharedKeyFile = "/etc/nixos/secrets/wireguard-presharedkey-op6t";
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };
}
