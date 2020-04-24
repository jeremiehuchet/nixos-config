{ config, lib, pkgs, ... }:

let
  cfg = config.custom.m1;
  shuttleSubnets = ../../secrets/m1-sshuttle-subnets;
in {

  options = { custom.m1.enable = lib.mkEnableOption "M1 tools"; };

  config = lib.mkIf cfg.enable {

    security.pki.certificates = [ (builtins.readFile ../../secrets/m1-ca.crt) ];

    systemd.services.m1-vpn-bridge = {
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
