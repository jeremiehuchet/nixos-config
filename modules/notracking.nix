{ lib, pkgs, config, ... }:

let
  nmCfg = config.networking.networkmanager;
  cfg = nmCfg.notracking;
in {
  options.networking.networkmanager.notracking = {
    enable = lib.mkEnableOption "Configure ad block list in dnsmasq";
  };

  config = lib.mkIf cfg.enable {

    assertions = [{
      assertion = nmCfg.dns == "dnsmasq";
      message = ''
        networking.networkmanager.notracking requires networking.networkmanager.dns to be "dnsmasq"
      '';
    }];

    environment.etc."NetworkManager/dnsmasq.d/notracking.conf".text = ''
      conf-file=${pkgs.nur.notracking}/domains.txt
      addn-hosts=${pkgs.nur.notracking}/hostnames.txt
    '';

  };
}
