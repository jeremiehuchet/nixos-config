{ config, lib, pkgs, ... }:

let
  # currentlycurrent v4l2loopback version (0.12.14) doesn't handle latest kernel
  v4l2loopback-0_12_5 = config.boot.kernelPackages.v4l2loopback.overrideAttrs
    (old: {
      src = pkgs.fetchFromGitHub {
        owner = "umlaeute";
        repo = "v4l2loopback";
        rev = "v0.12.5";
        hash = "sha256:1qi4l6yam8nrlmc3zwkrz9vph0xsj1cgmkqci4652mbpbzigg7vn";
      };
    });
  someoneWantsObsStudio =
    lib.attrsets.mapAttrsToList (userName: userCfg: userCfg.obs-studio.enable)
    config.custom.home;
  requireV4l2loopback = lib.foldr (x: y: x || y) false someoneWantsObsStudio;
in {
  imports = [ <home-manager/nixos> ];

  config = {

    boot = lib.mkIf requireV4l2loopback {
      kernelModules = [ "v4l2loopback" ];
      extraModulePackages = [ v4l2loopback-0_12_5 ];
      extraModprobeConfig = ''
        options v4l2loopback video_nr=10 card_label="OBS Video Source" exclusive_caps=1
      '';
    };

    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.obs-studio.enable {

        programs.obs-studio = {
          enable = true;
        };

      }) config.custom.home;
  };
}
