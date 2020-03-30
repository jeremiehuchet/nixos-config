# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let dpi = 140;
in {
  imports =
    [ ./tv/hardware-configuration.nix ./common.nix ../home ../custom-pkgs ];

  i18n.defaultLocale = "fr_FR.UTF-8";

  boot.supportedFilesystems = [ "nfs" ];

  services.autofs = {
    enable = true;
    autoMaster = let
      nasMapConf = pkgs.writeText "nas-auto" ''
        films  -rw,soft,intr nas:/mnt/md1/films
        music  -rw,soft,intr nas:/mnt/md1/music
        series -rw,soft,intr nas:/mnt/md1/series
      '';
    in ''
      /nas file:${nasMapConf} --timeout 30
    '';
  };

  networking.hostName = "tv";
  networking.enableIPv6 = false;
  networking.wireless.enable = true;
  networking.wireless.networks."L'internet de J".psk =
    (import ../secrets.nix).wireless.psk;
  networking.interfaces.ethernet.useDHCP = true;
  networking.interfaces.wireless.useDHCP = true;

  environment.systemPackages = with pkgs; [
    acpitool
    bazarr
    gnupg
    lm_sensors
    pass
    git
    kodi
    nfs-utils
  ];

  services.openssh.enable = true;

  services.udev.extraRules = ''
    # wake on usb
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usbhid", ATTR{../power/wakeup}="enabled"
    # network cards
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="f4:b7:e2:4b:d8:b7", NAME="wireless"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="b8:ca:3a:c8:30:f1", NAME="ethernet"
  '';

  sound.enable = true;
  sound.extraConfig = ''
    pcm.analog {
      type hw
      card 0
      device 0
    }
    pcm.hdmi0 {
      type hw
      card 0
      device 3
    }
    pcm.!default {
      type  plug
      slave.pcm "hdmi0"
    }
  '';

  services.xserver.libinput.enable = true;

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      IdleAction=suspend
      IdleActionSec=60
    '';
  };

  services.transmission = {
    enable = true;
    user = "guest";
    group = "users";
    settings = {
      download-dir = "/home/guest/torrent/finished";
      incomplete-dir = "/home/guest/torrent/incomplete";
      incomplete-dir-enabled = true;
    };
  };

  services.sonarr = {
    enable = true;
    user = "guest";
    group = "users";
    dataDir = "/home/guest/sonarr";
  };

  systemd.services.bazarr = {
    description = "Bazarr";
    after = [ "network.target" "sonarr.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "guest";
      Group = "users";
      ExecStart = "${pkgs.nur.bazarr}/bin/bazarr -c /home/guest/bazarr";
      Restart = "on-failure";
      TimeoutStopSec = 3;
    };
  };

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" ];
  };

  users.users.git = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [
      ../identities/id_rsa_laptop.pub
      ../identities/id_rsa_oneplus.pub
      ../identities/id_rsa_tv.pub
    ];
  };

  custom = {
    dpi = 140;
    xserver.autoLogin = "guest";
    xserver.primaryOutput = "HDMI-1";
    home.root.cliTools.enable = true;
    home.guest.cliTools.enable = true;
    home.guest.guiTools.enable = true;
    home.guest.guiTools.autoLock = false;
    home.guest.guiTools.i3statusRustConfig = ./tv/i3status-rust.toml;
  };

  system.stateVersion = "20.03";
}

