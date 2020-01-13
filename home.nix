{ pkgs, ... }:

{
  manual.html.enable = true;

  home.keyboard.layout = "fr";

  xsession = {
    enable = true;

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 64;
    };

    windowManager.i3 = {
      enable = true;
      config = {
      };
    };
  };

  services = {
    dunst.enable = true;
    udiskie.enable = true;
    network-manager-applet.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    google-chrome
    firefox
    jetbrains.idea-community
    terminator
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName  = "Jeremie Huchet";
    userEmail = "jeremiehuchet@users.noreply.github.com";
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
      glog = "log --graph --oneline --decorate --all";
    };
    extraConfig = {
      gui = {
	fontui = ''-family \"Noto Sans\" -size 12 -weight normal -slant roman -underline 0 -overstrike 0'';
	fontdiff = ''-family \"Noto Sans Mono\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'';
      };
    };
  };

  programs.rofi = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    userSettings = {
      "update.channel" = "none";
      "[nix]"."editor.tabSize" = 2;
    };
  };

  programs.vim = {
    enable = true;
    plugins = [
      pkgs.vimPlugins.vim-colors-solarized
      pkgs.vimPlugins.vim-nix
    ];
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.expireDuplicatesFirst = true;
    history.ignoreDups = false;
    oh-my-zsh.enable = true;
    oh-my-zsh.theme = "agnoster";
    oh-my-zsh.plugins = [
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
      "vagrant"
    ];
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        src = pkgs.zsh-syntax-highlighting;
      }
    ];
  };

}
