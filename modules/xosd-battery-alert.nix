{ lib, pkgs, config, ... }:

let
  cfg = config.services.xserver.xosdBatteryAlert;
  batteryAlert = pkgs.writeScriptBin "battery-alert" ''
    #!/usr/bin/env bash
    set -e

    PATH="${pkgs.xosd}/bin:${pkgs.utillinux}/bin:${pkgs.systemd}/bin:${pkgs.coreutils}/bin"

    XOSD="osd_cat --delay=10 --align=center --shadow=5"
    XOSD_NORMAL="$XOSD --font=-*-*-bold-*-*-*-72-240-*-*-*-*-*-*"
    XOSD_LARGE="$XOSD --font=-*-*-bold-*-*-*-144-480-*-*-*-*-*-*"

    log() {
      logger -t "$(basename $0)" "$@"
    }

    xosd() {
      delay=''${delay:-5}
      font=''${font:-'-*-*-bold-*-*-*-72-240-*-*-*-*-*-*'}
      for sessionId in $(loginctl --no-legend list-sessions | cut -d' ' -f1) ; do
        eval $(loginctl show-session -p Display -p Name $sessionId)
        if [ -n "$Display" ] ; then
          /run/wrappers/bin/sudo -u $Name \
              DISPLAY=$Display \
              osd_cat --font=$font --delay=$delay --align=center --shadow=5 "$@"
        fi
      done
    }

    xosd_large() {
      font='-*-*-bold-*-*-*-144-480-*-*-*-*-*-*'
      xosd --offset=100 "$@"
    }

    if [ -z "''${1//[^0-9]}" ] ; then
      log "invalid argument: $1"
      echo "Usage: $(basename $0) <battery percentage level>" | xosd --colour=red --pos=bottom --offset=100 &
      echo "'$1' is not an integer value"                     | xosd --colour=red --pos=bottom
      exit 1
    fi

    if [ $1 -le 5 ] ; then
      log "60 seconds count down before suspend"
      for i in $(seq 1 60 | sort -nr) ; do
        delay=1
        echo "SUSPENDING IN ''${i}s" | xosd_large --colour=red --pos=bottom
        if [[ "Charging" =~ $(cat /sys/class/power_supply/BAT0/status) ]] ; then
          log "the power supply as been plugged in"
          exit 0
        fi
      done
      log "triggering suspend"
      systemctl suspend
    elif [ $1 -le 10 ] ; then
      delay=10
      xosd --colour=red --pos=bottom --barmode=percentage --percentage=$1 &
      for i in $(seq 1 8) ; do
        delay=1
        sleep 0.2s
        echo "CRITICAL BATTERY LEVEL" | xosd_large --colour=red --pos=bottom --offset=-450
      done
    elif [ $1 -le 30 ] ; then
      xosd --colour=yellow --pos=bottom --barmode=percentage --percentage=$1 &
      echo "LOW BATTERY" | xosd_large --colour=yellow --pos=bottom --offset=-450
    else
      xosd --colour=green --pos=bottom --barmode=percentage --percentage=$1
    fi
  '';
in {
  options.services.xserver.xosdBatteryAlert = {
    enable =
      lib.mkEnableOption "Configure Xorg OSD battery level notifications";
  };

  config = lib.mkIf cfg.enable {

    services.udev.extraRules = ''
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]",      RUN+="${batteryAlert}/bin/battery-alert $attr{capacity}"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[6-9]|10",   RUN+="${batteryAlert}/bin/battery-alert $attr{capacity}"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="1[1-9]|20",  RUN+="${batteryAlert}/bin/battery-alert $attr{capacity}"
      SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="4[1-9]|50",  RUN+="${batteryAlert}/bin/battery-alert $attr{capacity}"
    '';

  };
}
