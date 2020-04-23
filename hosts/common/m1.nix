{ config, lib, pkgs, ... }:

let shuttleSubnets = ../../secrets/m1-sshuttle-subnets;
in {

  options = { custom.m1.enable = lib.mkEnableOption "M1 tools"; };

  config = {

    security.pki.certificates = [ (builtins.readFile ../../secrets/m1-ca.crt) ];

    systemd.services.m1-vpn-bridge = lib.mkIf config.custom.m1.enable {
      description = "M1 VPN bridge";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.sshuttle}/bin/sshuttle -r jeremie@192.168.1.151 --dns --subnets ${shuttleSubnets}";
        Restart = "on-failure";
      };
    };
  };
}
