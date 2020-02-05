{ pkgs, lib, ... }:

let
  lockCmd =
    "${pkgs.i3lock}/bin/i3lock --nofork --show-failed-attempts --ignore-empty-password --color 202020";
in {
  imports = [ ../custom-pkgs ];

  manual.html.enable = true;

  home.keyboard.layout = "fr";

  xresources.properties = { "Xft.dpi" = 192; };

  xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --dpi 192 --output DP-2 --primary
      ${pkgs.xorg.xbacklight}/bin/xbacklight -set $(cat ~/.config/i3/backlight.state)
    '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 64;
    };

    windowManager.i3 = {
      enable = true;
      config = let
        mod = "Mod1";
        ws1 = ''"1 "'';
        ws2 = ''"2 "'';
        ws3 = ''"3 "'';
        ws4 = ''"4 "'';
        ws5 = ''"5 "'';
        ws6 = ''"6 "'';
        ws7 = ''"7 "'';
        ws8 = ''"8 "'';
        ws9 = ''"9 "'';
        ws0 = ''"0 "'';
        output =
          "Output [E for external, L for laptop only, C for centered, (← → ↑ ↓) for position, Shift+(↑ ↓) for zoom]";
        resize =
          "Resize [ ← shrink width, → grow width, ↑ shrink height, ↓ grow height]";
        screenshot =
          "Screenshot [S for selection, W for active window] use Control modifier to save a file";
        systemControl =
          "System Control [S for shutdown, R for restart, E for logout, L for lock]";
      in {
        focus.followMouse = false;
        fonts = [ "NotoSansMono 8" ];
        floating.criteria = [{ class = "SimpleScreenRecorder"; }];
        modifier = "${mod}";
        keybindings = lib.mkOptionDefault {
          "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${mod}+o" = ''mode "${output}"'';
          "${mod}+p" = "exec ${pkgs.rofi-pass}/bin/rofi-pass";
          "${mod}+Shift+p" = "exec ${pkgs.rofi-pass}/bin/rofi-pass --last-used";
          "${mod}+Tab" = "exec rofi -show window";
          "${mod}+l" = "exec ${lockCmd}";
          "${mod}+r" = ''mode "${resize}"'';
          "${mod}+Shift+e" = ''mode "${systemControl}"'';
          "${mod}+s" = "layout stacking";
          "${mod}+z" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+q" = "focus parent";
          "${mod}+1" = "workspace ${ws1}";
          "${mod}+2" = "workspace ${ws2}";
          "${mod}+3" = "workspace ${ws3}";
          "${mod}+4" = "workspace ${ws4}";
          "${mod}+5" = "workspace ${ws5}";
          "${mod}+6" = "workspace ${ws6}";
          "${mod}+7" = "workspace ${ws7}";
          "${mod}+8" = "workspace ${ws8}";
          "${mod}+9" = "workspace ${ws9}";
          "${mod}+0" = "workspace ${ws0}";
          "${mod}+Shift+1" = "move container to workspace ${ws1}";
          "${mod}+Shift+2" = "move container to workspace ${ws2}";
          "${mod}+Shift+3" = "move container to workspace ${ws3}";
          "${mod}+Shift+4" = "move container to workspace ${ws4}";
          "${mod}+Shift+5" = "move container to workspace ${ws5}";
          "${mod}+Shift+6" = "move container to workspace ${ws6}";
          "${mod}+Shift+7" = "move container to workspace ${ws7}";
          "${mod}+Shift+8" = "move container to workspace ${ws8}";
          "${mod}+Shift+9" = "move container to workspace ${ws9}";
          "${mod}+Shift+0" = "move container to workspace ${ws0}";
          Print = ''mode "${screenshot}"'';
          # Pulse Audio controls
          XF86AudioRaiseVolume =
            "exec --no-startup-id amixer -q sset Master 5%+";
          XF86AudioLowerVolume =
            "exec --no-startup-id amixer -q sset Master 5%-";
          XF86AudioMute = "exec --no-startup-id amixer -q sset Master toggle";
          XF86AudioMicMute =
            "exec --no-startup-id amixer -q sset Capture toggle";
          # screen backlight
          XF86MonBrightnessUp =
            "exec --no-startup-id ${pkgs.xorg.xbacklight}/bin/xbacklight -inc 5 && ${pkgs.xorg.xbacklight}/bin/xbacklight -get > ~/.config/i3/backlight.state";
          XF86MonBrightnessDown =
            "exec --no-startup-id ${pkgs.xorg.xbacklight}/bin/xbacklight -dec 5 && ${pkgs.xorg.xbacklight}/bin/xbacklight -get > ~/.config/i3/backlight.state";
        };
        modes = {
          "${output}" = {
            l = "exec ${pkgs.pyrandr}/bin/pyrandr --laptop-only ; mode default";
            e =
              "exec ${pkgs.pyrandr}/bin/pyrandr --external-only ; mode default";
            c = "exec ${pkgs.pyrandr}/bin/pyrandr --position center-of-laptop";
            Left = "exec ${pkgs.pyrandr}/bin/pyrandr --position left-of-laptop";
            Right =
              "exec ${pkgs.pyrandr}/bin/pyrandr --position right-of-laptop";
            Up = "exec ${pkgs.pyrandr}/bin/pyrandr --position above-laptop";
            Down = "exec ${pkgs.pyrandr}/bin/pyrandr --position below-laptop";
            Prior = "exec ${pkgs.pyrandr}/bin/pyrandr --zoom 30";
            Next = "exec ${pkgs.pyrandr}/bin/pyrandr --zoom -30";
            "Control+Left" = "move workspace to output left";
            "Control+Right" = "move workspace to output right";
            "Control+Up" = "move workspace to output top";
            "Control+Down" = "move workspace to output bottom";
            "1" = "workspace ${ws1}";
            "2" = "workspace ${ws2}";
            "3" = "workspace ${ws3}";
            "4" = "workspace ${ws4}";
            "5" = "workspace ${ws5}";
            "6" = "workspace ${ws6}";
            "7" = "workspace ${ws7}";
            "8" = "workspace ${ws8}";
            "9" = "workspace ${ws9}";
            "0" = "workspace ${ws0}";
            Escape = "mode default";
            "${mod}+o" = "mode default";
          };
          "${resize}" = {
            Left = "resize shrink width 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
            Escape = "mode default";
            "${mod}+r" = "mode default";
          };
          "${screenshot}" = {
            # take a screenshot of the active [W]indow or given [S]election
            # the result is available in clipboard
            w =
              "exec --no-startup-id ${pkgs.maim}/bin/maim -i $(${pkgs.xdotool}/bin/xdotool getactivewindow) | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png ; mode default";
            "--release s" =
              "exec --no-startup-id ${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png ; mode default";
            # using Control modifier, the result is saved into ~/Pictures/maim-<date>.png
            "Control+w" =
              "exec --no-startup-id ${pkgs.maim}/bin/maim -i $(${pkgs.xdotool}/bin/xdotool getactivewindow) ~/Pictures/maim-$(date +%Y-%m-%d_%H-%M-%S).png ; mode default";
            "--release Control+s" =
              "exec --no-startup-id ${pkgs.maim}/bin/maim -s ~/Pictures/maim-$(date +%Y-%m-%d_%H-%M-%S).png ; mode default";
            Escape = "mode default";
            Print = "mode default";
          };
          "${systemControl}" = {
            e = "exec i3-msg exit; mode default";
            r = "exec reboot; mode default";
            s = "exec poweroff; mode default";
            l = "exec ${lockCmd}; mode default";
            Escape = "mode default";
            "${mod}+Shift+e" = "mode default";
          };
        };
        bars = [{
          position = "top";
          statusCommand =
            "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3/status.toml";
          fonts = [ "NotoSansMono 8" ];
        }];
      };
    };
  };

  xdg.configFile."i3/status.toml".source = ./i3status-rust.toml;
  xdg.configFile."terminator/config".source = ./terminator.toml;

  services = {
    dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          geometry = "600x5-30+50";
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          frame_color = "#aaaaaa";
          separator_height = 2;
          separator_color = "frame";
          font = "Noto Sans Mono 12";
          icon_position = "left";
          max_icon_size = 32;
          browser = "${pkgs.firefox}/bin/firefox";
        };
        urgency_low = {
          background = "#222222";
          foreground = "#888888";
          timeout = 10;
        };
        urgency_normal = {
          background = "#285577";
          foreground = "#ffffff";
          timeout = 10;
        };
        urgency_critical = {
          background = "#900000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 0;
          #icon = /path/to/icon;
        };
      };
    };
    gpg-agent.enable = true;
    gpg-agent.enableScDaemon = false;
    udiskie.enable = true;
    network-manager-applet.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = "${lockCmd}";
    };
    xsuspender.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    dolphin
    gimp
    google-chrome
    gnupg
    jetbrains.idea-community
    nixfmt
    mplayer
    pass
    pyrandr
    rofi-pass
    simplescreenrecorder
    slack
    terminator
    vagrant
  ];

  programs.firefox.enable = true;
  programs.firefox.extensions = [

  ];
  programs.firefox.profiles.jeremie = {
    id = 0;
    name = "Jeremie";
    userChrome = "#TabsToolbar { visibility: collapse !important; }";
    settings = {
      "browser.startup.homepage" = "about:blank";
      "browser.search.region" = "FR";
      "browser.search.isUS" = false;
      "distribution.searchplugins.defaultLocale" = "fr-FR";
      "general.useragent.locale" = "fr-FR";
      "browser.bookmarks.showMobileBookmarks" = true;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };
  };

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
          -family \"Noto Sans Mono\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'';
      };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "solarized";
    extraConfig = ''
      rofi.dpi: 192
    '';
  };

  programs.vscode = {
    enable = true;
    userSettings = {
      "update.channel" = "none";
      "editor.fontFamily" = "'Fira Code', 'Noto Color Emoji'";
      # font weight : 300 → light, 400 → regular, 500 → medium, 600 → bold
      "editor.fontWeight" = "400";
      "editor.fontLigatures" = true;
      "files.autoSave" = "onFocusChange";
      "[nix]"."editor.tabSize" = 2;
    };
  };

  programs.vim = {
    enable = true;
    plugins = [ pkgs.vimPlugins.vim-colors-solarized pkgs.vimPlugins.vim-nix ];
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
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
    ];
  };

}
