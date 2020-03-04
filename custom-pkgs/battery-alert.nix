{ pkgs, ... }:

pkgs.writeScriptBin "battery-alert" ''
  #!${pkgs.bash}/bin/bash
  
  LOG="${pkgs.utillinux}/bin/logger -t $(basename $0)"
  XOSD="${pkgs.xosd}/bin/osd_cat --delay=10 --align=center --shadow=5"
  XOSD_NORMAL="$XOSD --font=-*-*-bold-*-*-*-72-240-*-*-*-*-*-*"
  XOSD_LARGE="$XOSD --font=-*-*-bold-*-*-*-144-480-*-*-*-*-*-*"
  
  if [ -z "''${1//[^0-9]}" ] ; then
    $LOG "invalid argument: $1"
    echo "Usage: $(basename $0) <battery percentage level>" | $XOSD_NORMAL --colour=red --pos=bottom --offset=100 &
    echo "'$1' is not an integer value"                     | $XOSD_NORMAL --colour=red --pos=bottom
    exit 1
  fi

  if [ $1 -le 10 ] ; then
    ALERT_CMD="$XOSD_LARGE --colour=red --pos=bottom --barmode=percentage --percentage=$1 -T \"CRITICAL BATTERY LEVEL\""
  elif [ $1 -le 30 ] ; then
    ALERT_CMD="$XOSD_LARGE --colour=yellow --pos=bottom --barmode=percentage --percentage=$1 -T \"LOW BATTERY\""
  else
    ALERT_CMD="$XOSD_LARGE --colour=green --pos=bottom --barmode=percentage --percentage=$1"
  fi

  $LOG "$ALERT_CMD"
  DISPLAY=:0 $ALERT_CMD
  exit $?
''
