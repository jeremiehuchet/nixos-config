{ config, lib, pkgs, ... }:

let
  cfg = config.custom.m0;
  secrets = import ../../secrets.nix;
  secretFiles = ../../secrets;
in {
  options = { custom.m0.enable = lib.mkEnableOption "M0 tools"; };

  config = lib.mkIf cfg.enable {

  };
}
