{ config, lib, pkgs, ... }:

{
  imports = [ ../home-manager/nixos ];

  config = {

    users.users = lib.mapAttrs (name: userCfg: {

      shell = pkgs.zsh;

    }) config.custom.home;

    home-manager.users = lib.mapAttrs (name: userCfg:

      lib.mkIf userCfg.cliTools.enable {

        home.packages = with pkgs; [
          cachix
          dfc
          nur.gitmoji-cli
          httpie
          jq
          nixfmt
          p7zip
          pass
          pretty-nixos-rebuild
          pyrandr
          speedtest-cli
          tree
        ];

        xdg.configFile."gitmoji-nodejs/config.json".source = ./gitmoji.json;

        programs.broot.enable = true;

        programs.git = {
          enable = true;
          package = pkgs.gitAndTools.gitFull;
          userName = "Jeremie Huchet";
          userEmail = "jeremiehuchet@users.noreply.github.com";
          aliases = {
            co = "checkout";
            ci = "commit";
            st = "status";
            glog = "log --graph --oneline --decorate --all";
          };
          extraConfig = {
            gui = {
              fontui = ''
                -family \"Noto Sans\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0'';
              fontdiff = ''
                -family \"Fira Code Retina\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'';
            };
          };
        };

        programs.htop = {
          enable = true;
          detailedCpuTime = true;
          showProgramPath = false;
          meters.left = [ "LeftCPUs2" "Memory" "Swap" ];
          meters.right = [
            "RightCPUs2"
            {
              kind = "Tasks";
              mode = 2;
            }
            {
              kind = "LoadAverage";
              mode = 2;
            }
            {
              kind = "Uptime";
              mode = 2;
            }
          ];
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
            "colorize"
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
