{ config, lib, pkgs, ... }:

with lib;

{
  imports = import ../../modules;

  options = {
    custom = {
      dpi = mkOption {
        default = 92;
        type = types.int;
      };
      xserver = { autoLogin = mkOption { type = types.str; }; };
    };
  };

  config = {
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.configurationLimit = 30;
    #boot.tmp.cleanOnBoot = true;

    console.earlySetup = true;
    console.keyMap = "fr";

    time.timeZone = "Europe/Paris";

    security.sudo.extraConfig = "Defaults timestamp_timeout=10";

    fonts = {
      enableDefaultPackages = false;
      enableGhostscriptFonts = true;
      fontconfig.defaultFonts = {
        emoji = [ "Noto Color Emoji" "Font Awesome 6 Free" ];
        monospace = [ "Fira Code Regular" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Sans Serif" ];
      };
      packages = with pkgs; [
        dejavu_fonts
        emacs-all-the-icons-fonts
        fira-code
        font-awesome
        noto-fonts-emoji
        noto-fonts
      ];
    };

    services = {
      displayManager = {
        defaultSession = "none+i3";
        autoLogin = {
          enable = true;
          user = config.custom.xserver.autoLogin;
        };
      };

      xserver = {
        enable = true;
        dpi = config.custom.dpi;
        xkb.layout = "fr";
        windowManager.i3.enable = true;
      };
    };

    programs.vim.enable = true;
    programs.vim.defaultEditor = true;
    programs.zsh.enable = true;
    programs.zsh.promptInit =
      "any-nix-shell zsh --info-right | source /dev/stdin";

    environment.pathsToLink = [ "/share/zsh" ];

    environment.systemPackages = with pkgs; [
      any-nix-shell
      gitAndTools.gitFull
      hicolor-icon-theme
      kdePackages.breeze-icons
      libu2f-host
      lm_sensors
    ];

    services.kmscon.enable = true;
    services.kmscon.extraConfig = ''
      xkb-layout=fr
      xkb-variant=fr
    '';

    nix = {
      nixPath = (import ../../pinned-channels).nixPath;
      gc.automatic = true;
      gc.dates = "weekly";
      gc.options = "--delete-older-than 30d";
      settings.auto-optimise-store = true;
      settings.substituters =
        [ "https://cachix.cachix.org" "https://jeremiehuchet.cachix.org" ];
      settings.trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "jeremiehuchet.cachix.org-1:NPQGzLT375jYLfRiIAsSierm0DJX1PlgMjczQVtIZYM="
      ];
    };

    system.activationScripts = {
      shebangFix = ''
        ln -fs ${pkgs.bash}/bin/bash /bin/bash
      '';
    };

  };
}
