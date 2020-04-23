{ config, lib, pkgs, ... }:

{
  imports = [ ../home-manager/nixos ];

  config = {

    system.activationScripts = {
      jdks = ''
        mkdir -p /opt
        chmod 777 /opt
        rm -f /opt/openjdk{8,11}
        ln -s ${pkgs.openjdk8} /opt/openjdk8
        ln -s ${pkgs.openjdk11} /opt/openjdk11
      '';
    };

    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.devTools.enable {

        home.packages = with pkgs; [
          unstable.android-studio
          docker-compose
          gitAndTools.hub
          graphviz
          unstable.jetbrains.idea-community
          nur.now
          openjdk11
          remmina
          shellcheck
          slack
          teams
          unstable.travis
          vagrant
        ];

        programs.vscode = {
          enable = true;
          userSettings = {
            "update.mode" = "none";
            "editor.fontFamily" =
              "'Fira Code Retina', 'Noto Color Emoji', 'Font Awesome 5 Brands', 'Font Awesome 5 Free'";
            # font weight : 300 → light, 400 → regular, 500 → medium, 600 → bold
            "editor.fontWeight" = "400";
            "editor.fontLigatures" = true;
            "files.autoSave" = "onFocusChange";
            "[nix]"."editor.tabSize" = 2;
            "java.home" = "${pkgs.jdk11}";
            "local-history.path" = "~/.config/Code/local-history";
          };
        };

      }) config.custom.home;
  };
}
