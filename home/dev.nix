{ config, lib, pkgs, ... }:

let unstable = import <nixpkgs-unstable> { };
in {
  imports = [ ../home-manager/nixos ];

  config = {
    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.devTools.enable {

        home.packages = with pkgs; [
          unstable.android-studio
          docker-compose
          nur.gitmoji-cli
          jetbrains.idea-community
          nur.now
          openjdk11
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
