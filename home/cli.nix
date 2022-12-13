{ config, lib, pkgs, ... }:

{
  imports = [ <home-manager/nixos> ];

  config = {

    users.users = lib.mapAttrs (name: userCfg: {

      shell = pkgs.zsh;

    }) config.custom.home;

    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.cliTools.enable {

        home.packages = with pkgs; [
          unstable.bpytop
          cachix
          dnsutils
          nur.ccat
          dfc
          nur.gitmoji-cli
          gnupg
          httpie
          jq
          nixfmt
          p7zip
          (pass.withExtensions (exts: [ exts.pass-update ]))
          pdftk
          pretty-nixos-rebuild
          nur.pyrandr
          speedtest-cli
          tree
          wget
          nur.webtorrent-cli
        ];

        xdg.configFile."gitmoji-nodejs/config.json".source = ./gitmoji.json;

        programs.broot.enable = true;

        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          config = {
            bash_path = "${pkgs.bash}/bin/bash";
            strict_env = true;
          };
        };
        xdg.configFile."direnv/direnvrc".source =
          "${pkgs.nur.nix-direnv}/share/nix-direnv/direnvrc";

        programs.git = {
          enable = true;
          package = pkgs.gitAndTools.gitFull;
          userName = "Jeremie Huchet";
          userEmail = "jeremiehuchet@users.noreply.github.com";
          aliases = {
            co = "checkout";
            ci = "commit";
            mj = "!gitmoji -c";
            st = "status";
            glog = "log --graph --oneline --decorate --all";
          };
          extraConfig = {
            credential = { helper = "store"; };
            gui = {
              fontui = ''
                -family "Noto Sans" -size 12 -weight normal -slant roman -underline 0 -overstrike 0'';
              fontdiff = ''
                -family "Fira Code Regular" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'';
            };
          };
        };

        programs.htop = {
          enable = true;
          settings = {
            detailed_cpu_time = true;
            show_program_path = false;
            left_meters = [ "LeftCPUs2" "Memory" "Swap" ];
            right_meters = [ "RightCPUs2" "Tasks" "LoadAverage" "Uptime" ];
            right_meters_modes = [ 1 2 2 2 ];
          };
        };

        programs.vim = {
          enable = true;
          plugins =
            [ pkgs.vimPlugins.vim-colors-solarized pkgs.vimPlugins.vim-nix ];
        };

        programs.zsh = {
          enable = true;
          enableAutosuggestions = true;
          enableCompletion = true;
          history = {
            expireDuplicatesFirst = true;
            ignoreDups = false;
            share = false;
          };
          localVariables = { DEFAULT_USER = "jeremie"; };
          oh-my-zsh.enable = true;
          oh-my-zsh.theme = "agnoster";
          oh-my-zsh.plugins = [
            "ansible"
            "colored-man-pages"
            "git"
            "git-extras"
            "gradle"
            "httpie"
            "mvn"
            "npm"
            "nvm"
            "pip"
            "rvm"
            "systemd"
            "vagrant"
          ];
          plugins = [{
            name = "zsh-syntax-highlighting";
            file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
            src = pkgs.zsh-syntax-highlighting;
          }];
        };

      }) config.custom.home;
  };
}
