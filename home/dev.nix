{ config, lib, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

  config = {

    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.devTools.enable {

        home.file.".sdks/openjdk8".source = pkgs.openjdk8;
        home.file.".sdks/openjdk11".source = pkgs.openjdk11;
        home.file.".sdks/groovy".source = pkgs.groovy;

        home.packages = with pkgs; [
          unstable.android-studio
          docker-compose
          gitAndTools.hub
          graphviz
          groovy
          unstable.jetbrains.idea-community
          maven
          unstable.minikube unstable.kubectl
          nodejs-12_x
          nur.now
          openjdk11
          unstable.packer
          pgcli
          remmina
          shellcheck
          slack
          teams
          unstable.terraform
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
