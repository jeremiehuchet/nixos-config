{ config, lib, pkgs, ... }:

with lib;

let
  userHomeOptions = { name, config, ... }: {
    options = {
      cliTools.enable = mkEnableOption "CLI essential tools";
      guiTools.enable = mkEnableOption "X server and GUI essential tools";
      guiTools.autoLock = mkOption {
        default = true;
        type = types.bool;
      };
      guiTools.i3statusRustConfig = mkOption { type = types.path; };
      devTools.enable = mkEnableOption "Development tools";
      obs-studio.enable = mkEnableOption "OBS Studio tools";
    };
  };
in {
  options = {
    custom.home = mkOption {
      default = { };
      type = with types; loaOf (submodule userHomeOptions);
      example = {
        alice = {
          cliTools.enable = true;
          guiTools = {
            enable = true;
            autoLock = false;
          };
          devTools.enable = false;
        };
      };
    };
  };

  imports = [ ./cli.nix ./gui.nix ./dev.nix ];

  config = {

    home-manager.users = mapAttrs (name: userCfg: {

      home.stateVersion = "20.03";
      home.keyboard.layout = "fr";
      manual.html.enable = true;

    }) config.custom.home;
  };
}
