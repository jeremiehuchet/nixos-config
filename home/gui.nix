{ config, lib, pkgs, ... }:

let
  cfg.dpi = toString config.custom.dpi;
  cfg.primaryOutput = config.custom.xserver.primaryOutput;
in {
  imports = [ <home-manager/nixos> ];

  options = with lib; {
    custom.xserver = { primaryOutput = mkOption { type = types.str; }; };
  };

  config = {
    home-manager.users = lib.mapAttrs (name: userCfg:

      let
        xlock = pkgs.writeScriptBin "xlock" ''
          #!${pkgs.bash}/bin/bash
          PATH="${pkgs.xorg.xbacklight}/bin:${pkgs.i3lock}/bin:${pkgs.coreutils}/bin"
          xbacklight -get > /home/${name}/.config/i3/backlight.state
          xbacklight -set 10
          i3lock --nofork --show-failed-attempts --ignore-empty-password --color ffffff || exit 1
          xbacklight -set $(cat /home/${name}/.config/i3/backlight.state)
        '';
        lockCmd = "${xlock}/bin/xlock";
      in lib.mkIf userCfg.guiTools.enable {

        nixpkgs.config.allowUnfree = true;

        home.packages = with pkgs; [
          dolphin
          gimp
          google-chrome
          libreoffice
          mplayer
          simplescreenrecorder
          terminator
        ];

        xresources.properties = {
          "Xft.dpi" = cfg.dpi;
          "Xft.autohint" = 0;
          "Xft.lcdfilter" = "lcddefault";
          "Xft.hintstyle" = "hintfull";
          "Xft.hinting" = 1;
          "Xft.antialias" = 1;
          "Xft.rgba" = "rgb";
        };

        xsession = {
          enable = true;
          initExtra = ''
            ${pkgs.xorg.xrandr}/bin/xrandr --dpi ${cfg.dpi} --output ${cfg.primaryOutput} --primary
            ${pkgs.nur.pyrandr}/bin/pyrandr --laptop-only
            ${pkgs.xorg.xbacklight}/bin/xbacklight -set $(cat ~/.config/i3/backlight.state)
          '';
          profileExtra = ''
            export GDK_SCALE=2
            export GDK_DPI_SCALE=0.5
            export QT_AUTO_SCREEN_SCALE_FACTOR=1
          '';
          pointerCursor = {
            package = pkgs.vanilla-dmz;
            name = "Vanilla-DMZ";
            size = 64;
          };

          windowManager.i3 = {
            enable = true;
            config = let
              mod = "Mod4";
              ws1 = ''"1 "'';
              ws2 = ''"2 "'';
              ws3 = ''"3 "'';
              ws4 = ''"4 "'';
              ws5 = ''"5 "'';
              ws6 = ''"6 "'';
              ws7 = ''"7 "'';
              ws8 = ''"8 "'';
              ws9 = ''"9 "'';
              ws0 = ''"10 "'';
              output =
                "Output [E for external, L for laptop only, C for centered, (← → ↑ ↓) for position, Shift+(↑ ↓) for zoom]";
              resize =
                "Resize [ ← shrink width, → grow width, ↑ shrink height, ↓ grow height]";
              screenshot =
                "Screenshot [S for selection, W for active window] use Control modifier to save a file";
              systemControl =
                "System Control [Ctrl+S for suspend, S for shutdown, R for restart, E for logout, L for lock]";
            in {
              focus.followMouse = false;
              fonts = [ "Fira Code Retina 9" ];
              floating.criteria = [
                { class = "SimpleScreenRecorder"; }
                { class = "Git-gui"; }
                { class = "Gitk"; }
                { instance = "sun-awt-X11-XDialogPeer"; }
              ];
              modifier = "${mod}";
              startup = [{
                command = " i3-msg workspace ${ws1}";
                notification = false;
              }];
              keybindings = lib.mkOptionDefault {
                "${mod}+Return" =
                  "exec ${pkgs.terminator}/bin/terminator --working-directory $(${pkgs.xcwd}/bin/xcwd)";
                "${mod}+b" =
                  "exec ${pkgs.nur.rofi-bookmarks}/bin/rofi-bookmarks";
                "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
                "${mod}+i" = "exec ${pkgs.nur.rofimoji}/bin/rofimoji";
                "${mod}+o" = ''mode "${output}"'';
                "${mod}+p" = "exec ${pkgs.rofi-pass}/bin/rofi-pass";
                "${mod}+Shift+p" =
                  "exec ${pkgs.rofi-pass}/bin/rofi-pass --last-used";
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
                XF86AudioMute =
                  "exec --no-startup-id amixer -q sset Master toggle";
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
                  l =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --laptop-only ; mode default";
                  e =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --external-only ; mode default";
                  c =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --position center-of-laptop";
                  Left =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --position left-of-laptop";
                  Right =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --position right-of-laptop";
                  Up =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --position above-laptop";
                  Down =
                    "exec ${pkgs.nur.pyrandr}/bin/pyrandr --position below-laptop";
                  Prior = "exec ${pkgs.nur.pyrandr}/bin/pyrandr --zoom 30";
                  Next = "exec ${pkgs.nur.pyrandr}/bin/pyrandr --zoom -30";
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
                  "Control+s" =
                    "exec ${pkgs.systemd}/bin/systemctl suspend; mode default";
                  l = "exec ${lockCmd}; mode default";
                  Escape = "mode default";
                  "${mod}+Shift+e" = "mode default";
                };
              };
              bars = [{
                position = "top";
                statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs "
                  + userCfg.guiTools.i3statusRustConfig;
                fonts = [ "Fira Code Retina 9" ];
              }];
            };
          };
        };

        xdg.configFile."terminator/config".source = ./terminator.toml;

        services = {
          dunst = {
            enable = true;
            settings = {
              global = {
                follow = "mouse";
                geometry = "900x10-30+50";
                padding = 8;
                horizontal_padding = 8;
                frame_width = 2;
                frame_color = "#aaaaaa";
                separator_height = 2;
                separator_color = "frame";
                font = "Fira Code Retina 12";
                icon_position = "left";
                max_icon_size = 32;
                browser = "${pkgs.google-chrome}/bin/google-chrome-stable";
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
          gpg-agent.pinentryFlavor = "qt";
          udiskie.enable = true;
          network-manager-applet.enable = true;
          screen-locker = {
            enable = userCfg.guiTools.autoLock;
            lockCmd = "${lockCmd}";
          };
        };

        programs.rofi = {
          enable = true;
          theme = "solarized";
          extraConfig = ''
            rofi.dpi: ${cfg.dpi}
          '';
        };

      }) config.custom.home;
  };
}
