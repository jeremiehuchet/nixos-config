{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.wayland.windowManager.sway;

  commonOptions = import ./lib/options.nix {
    inherit lib cfg pkgs;
    moduleName = "sway";
    capitalModuleName = "Sway";
  };

  configModule = types.submodule {
    options = {
      inherit (commonOptions)
        fonts window floating focus assigns workspaceLayout
        workspaceAutoBackAndForth modifier keycodebindings colors bars startup
        gaps menu terminal;

      left = mkOption {
        type = types.str;
        default = "h";
        description = "Home row direction key for moving left.";
      };

      down = mkOption {
        type = types.str;
        default = "j";
        description = "Home row direction key for moving down.";
      };

      up = mkOption {
        type = types.str;
        default = "k";
        description = "Home row direction key for moving up.";
      };

      right = mkOption {
        type = types.str;
        default = "l";
        description = "Home row direction key for moving right.";
      };

      keybindings = mkOption {
        type = types.attrsOf (types.nullOr types.str);
        default = mapAttrs (n: mkOptionDefault) {
          "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
          "${cfg.config.modifier}+Shift+q" = "kill";
          "${cfg.config.modifier}+d" = "exec ${cfg.config.menu}";

          "${cfg.config.modifier}+${cfg.config.left}" = "focus left";
          "${cfg.config.modifier}+${cfg.config.down}" = "focus down";
          "${cfg.config.modifier}+${cfg.config.up}" = "focus up";
          "${cfg.config.modifier}+${cfg.config.right}" = "focus right";

          "${cfg.config.modifier}+Left" = "focus left";
          "${cfg.config.modifier}+Down" = "focus down";
          "${cfg.config.modifier}+Up" = "focus up";
          "${cfg.config.modifier}+Right" = "focus right";

          "${cfg.config.modifier}+Shift+${cfg.config.left}" = "move left";
          "${cfg.config.modifier}+Shift+${cfg.config.down}" = "move down";
          "${cfg.config.modifier}+Shift+${cfg.config.up}" = "move up";
          "${cfg.config.modifier}+Shift+${cfg.config.right}" = "move right";

          "${cfg.config.modifier}+Shift+Left" = "move left";
          "${cfg.config.modifier}+Shift+Down" = "move down";
          "${cfg.config.modifier}+Shift+Up" = "move up";
          "${cfg.config.modifier}+Shift+Right" = "move right";

          "${cfg.config.modifier}+b" = "splith";
          "${cfg.config.modifier}+v" = "splitv";
          "${cfg.config.modifier}+f" = "fullscreen toggle";
          "${cfg.config.modifier}+a" = "focus parent";

          "${cfg.config.modifier}+s" = "layout stacking";
          "${cfg.config.modifier}+w" = "layout tabbed";
          "${cfg.config.modifier}+e" = "layout toggle split";

          "${cfg.config.modifier}+Shift+space" = "floating toggle";
          "${cfg.config.modifier}+space" = "focus mode_toggle";

          "${cfg.config.modifier}+1" = "workspace number 1";
          "${cfg.config.modifier}+2" = "workspace number 2";
          "${cfg.config.modifier}+3" = "workspace number 3";
          "${cfg.config.modifier}+4" = "workspace number 4";
          "${cfg.config.modifier}+5" = "workspace number 5";
          "${cfg.config.modifier}+6" = "workspace number 6";
          "${cfg.config.modifier}+7" = "workspace number 7";
          "${cfg.config.modifier}+8" = "workspace number 8";
          "${cfg.config.modifier}+9" = "workspace number 9";

          "${cfg.config.modifier}+Shift+1" =
            "move container to workspace number 1";
          "${cfg.config.modifier}+Shift+2" =
            "move container to workspace number 2";
          "${cfg.config.modifier}+Shift+3" =
            "move container to workspace number 3";
          "${cfg.config.modifier}+Shift+4" =
            "move container to workspace number 4";
          "${cfg.config.modifier}+Shift+5" =
            "move container to workspace number 5";
          "${cfg.config.modifier}+Shift+6" =
            "move container to workspace number 6";
          "${cfg.config.modifier}+Shift+7" =
            "move container to workspace number 7";
          "${cfg.config.modifier}+Shift+8" =
            "move container to workspace number 8";
          "${cfg.config.modifier}+Shift+9" =
            "move container to workspace number 9";

          "${cfg.config.modifier}+Shift+minus" = "move scratchpad";
          "${cfg.config.modifier}+minus" = "scratchpad show";

          "${cfg.config.modifier}+Shift+c" = "reload";
          "${cfg.config.modifier}+Shift+r" = "restart";
          "${cfg.config.modifier}+Shift+e" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

          "${cfg.config.modifier}+r" = "mode resize";
        };
        defaultText = "Default sway keybindings.";
        description = ''
          An attribute set that assigns a key press to an action using a key symbol.
          See <link xlink:href="https://i3wm.org/docs/userguide.html#keybindings"/>.
          </para><para>
          Consider to use <code>lib.mkOptionDefault</code> function to extend or override
          default keybindings instead of specifying all of them from scratch.
        '';
        example = literalExample ''
          let
            modifier = cfg.config.modifier;
          in

          lib.mkOptionDefault {
            "''${modifier}+Return" = "exec ${cfg.config.terminal}";
            "''${modifier}+Shift+q" = "kill";
            "''${modifier}+d" = "exec ${cfg.config.menu}";
          }
        '';
      };

      input = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = { };
        example = { "*" = { xkb_variant = "dvorak"; }; };
        description = ''
          An attribute set that defines input modules. See man sway_input for options.
        '';
      };

      output = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = { };
        example = { "HDMI-A-2" = { bg = "~/path/to/background.png"; }; };
        description = ''
          An attribute set that defines output modules. See man sway_output for options.
        '';
      };

      modes = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = {
          resize = {
            "${cfg.config.left}" = "resize shrink width 10 px";
            "${cfg.config.down}" = "resize grow height 10 px";
            "${cfg.config.up}" = "resize shrink height 10 px";
            "${cfg.config.right}" = "resize grow width 10 px";
            "Left" = "resize shrink width 10 px";
            "Down" = "resize grow height 10 px";
            "Up" = "resize shrink height 10 px";
            "Right" = "resize grow width 10 px";
            "Escape" = "mode default";
            "Return" = "mode default";
          };
        };
        description = ''
          An attribute set that defines binding modes and keybindings
          inside them

          Only basic keybinding is supported (bindsym keycomb action),
          for more advanced setup use 'sway.extraConfig'.
        '';
      };
    };
  };

  wrapperOptions = types.submodule {
    options = let
      mkWrapperFeature = default: description:
        mkOption {
          type = types.bool;
          inherit default;
          example = !default;
          description = "Whether to make use of the ${description}";
        };
    in {
      base = mkWrapperFeature true ''
        base wrapper to execute extra session commands and prepend a
        dbus-run-session to the sway command.
      '';
      gtk = mkWrapperFeature false ''
        wrapGAppsHook wrapper to execute sway with required environment
        variables for GTK applications.
      '';
    };
  };

  commonFunctions = import ./lib/functions.nix {
    inherit cfg lib;
    moduleName = "sway";
  };

  inherit (commonFunctions)
    keybindingsStr keycodebindingsStr modeStr assignStr barStr gapsStr
    floatingCriteriaStr windowCommandsStr colorSetStr;

  startupEntryStr = { command, always, ... }: ''
    ${if always then "exec_always" else "exec"} ${command}
  '';

  inputStr = name: attrs: ''
    input "${name}" {
    ${concatStringsSep "\n"
    (mapAttrsToList (name: value: "${name} ${value}") attrs)}
    }
  '';

  outputStr = name: attrs: ''
    output "${name}" {
    ${concatStringsSep "\n"
    (mapAttrsToList (name: value: "${name} ${value}") attrs)}
    }
  '';

  configFile = pkgs.writeText "sway.conf" ((if cfg.config != null then
    with cfg.config; ''
      font pango:${concatStringsSep ", " fonts}
      floating_modifier ${floating.modifier}
      default_border ${if window.titlebar then "normal" else "pixel"} ${
        toString window.border
      }
      default_floating_border ${
        if floating.titlebar then "normal" else "pixel"
      } ${toString floating.border}
      hide_edge_borders ${window.hideEdgeBorders}
      focus_wrapping ${if focus.forceWrapping then "yes" else "no"}
      focus_follows_mouse ${if focus.followMouse then "yes" else "no"}
      focus_on_window_activation ${focus.newWindow}
      mouse_warping ${if focus.mouseWarping then "output" else "none"}
      workspace_layout ${workspaceLayout}
      workspace_auto_back_and_forth ${
        if workspaceAutoBackAndForth then "yes" else "no"
      }

      client.focused ${colorSetStr colors.focused}
      client.focused_inactive ${colorSetStr colors.focusedInactive}
      client.unfocused ${colorSetStr colors.unfocused}
      client.urgent ${colorSetStr colors.urgent}
      client.placeholder ${colorSetStr colors.placeholder}
      client.background ${colors.background}

      ${keybindingsStr keybindings}
      ${keycodebindingsStr keycodebindings}
      ${concatStringsSep "\n" (mapAttrsToList inputStr input)}
      ${concatStringsSep "\n" (mapAttrsToList outputStr output)}
      ${concatStringsSep "\n" (mapAttrsToList modeStr modes)}
      ${concatStringsSep "\n" (mapAttrsToList assignStr assigns)}
      ${concatStringsSep "\n" (map barStr bars)}
      ${optionalString (gaps != null) gapsStr}
      ${concatStringsSep "\n" (map floatingCriteriaStr floating.criteria)}
      ${concatStringsSep "\n" (map windowCommandsStr window.commands)}
      ${concatStringsSep "\n" (map startupEntryStr startup)}
    ''
  else
    "") + "\n" + (if cfg.systemdIntegration then ''
      exec "systemctl --user import-environment; systemctl --user start sway-session.target"
    '' else
      "") + cfg.extraConfig);

  defaultSwayPackage = pkgs.sway.override {
    extraSessionCommands = cfg.extraSessionCommands;
    extraOptions = cfg.extraOptions;
    withBaseWrapper = cfg.wrapperFeatures.base;
    withGtkWrapper = cfg.wrapperFeatures.gtk;
  };

in {
  options.wayland.windowManager.sway = {
    enable = mkEnableOption "sway wayland compositor";

    package = mkOption {
      type = types.package;
      default = defaultSwayPackage;
      defaultText = literalExample "${pkgs.sway}";
      description = ''
        Sway package to use. Will override the options 'wrapperFeatures', 'extraSessionCommands', and 'extraOptions'.
      '';
    };

    systemdIntegration = mkOption {
      type = types.bool;
      default = pkgs.stdenv.isLinux;
      example = false;
      description = ''
        Whether to enable <filename>sway-session.target</filename> on
        sway startup. This links to
        <filename>graphical-session.target</filename>.
      '';
    };

    xwayland = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable xwayland, which is needed for the default configuration of sway.
      '';
    };

    wrapperFeatures = mkOption {
      type = wrapperOptions;
      default = { };
      example = { gtk = true; };
      description = ''
        Attribute set of features to enable in the wrapper.
      '';
    };

    extraSessionCommands = mkOption {
      type = types.lines;
      default = "";
      example = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      description = ''
        Shell commands executed just before Sway is started.
      '';
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "--verbose"
        "--debug"
        "--unsupported-gpu"
        "--my-next-gpu-wont-be-nvidia"
      ];
      description = ''
        Command line arguments passed to launch Sway. Please DO NOT report
        issues if you use an unsupported GPU (proprietary drivers).
      '';
    };

    config = mkOption {
      type = types.nullOr configModule;
      default = { };
      description = "Sway configuration options.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description =
        "Extra configuration lines to add to ~/.config/sway/config.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] ++ optional cfg.xwayland pkgs.xwayland;
    xdg.configFile."sway/config" = {
      source = configFile;
      onChange = ''
        swaySocket=''${XDG_RUNTIME_DIR:-/run/user/$UID}/sway-ipc.$UID.*.sock
        if [ -S $swaySocket ]; then
          echo "Reloading sway"
          $DRY_RUN_CMD ${cfg.package}/bin/swaymsg -s $swaySocket reload
        fi
      '';
    };
    systemd.user.targets.sway-session = mkIf cfg.systemdIntegration {
      Unit = {
        Description = "sway compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };
  };
}
