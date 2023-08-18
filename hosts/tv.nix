# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  disabledModules = [
    "services/home-automation/home-assistant.nix"
  ];

  imports = [
    ./tv/hardware-configuration.nix
    ./common
    ../home
    ../custom-pkgs
    <nixpkgs-unstable/nixos/modules/services/home-automation/home-assistant.nix>
    ./tv/fail2ban.nix
    ./tv/dyndns.nix
    ./tv/hass
    ./tv/vpn.nix
  ];

  i18n.defaultLocale = "fr_FR.UTF-8";

  boot.supportedFilesystems = [ "nfs" ];

  hardware.fancontrol.enable = true;
  hardware.fancontrol.config = ''
    # Configuration file generated by pwmconfig, changes will be lost
    INTERVAL=10
    DEVPATH=hwmon0=devices/platform/coretemp.0 hwmon1=devices/platform/dell_smm_hwmon
    DEVNAME=hwmon0=coretemp hwmon1=dell_smm
    FCTEMPS=hwmon1/pwm1=hwmon0/temp1_input
    FCFANS= hwmon1/pwm1=hwmon1/fan1_input
    MINTEMP=hwmon1/pwm1=57
    MAXTEMP=hwmon1/pwm1=70
    MINSTART=hwmon1/pwm1=120
    MINSTOP=hwmon1/pwm1=75
  '';

  services.autofs = {
    enable = true;
    autoMaster = let
      nasMapConf = pkgs.writeText "nas-auto" ''
        films  -rw,soft,intr,sync nas:/mnt/md1/films
        music  -rw,soft,intr,sync nas:/mnt/md1/music
        series -rw,soft,intr,sync nas:/mnt/md1/series
        photos -rw,soft,intr,sync nas:/mnt/md1/photos
        backup -rw,soft,intr,sync nas:/mnt/md1/backup
      '';
    in ''
      /nas file:${nasMapConf} --timeout 30
    '';
  };

  systemd.network.links."10-wireless" = {
    matchConfig.MACAddress = "28:87:ba:cc:d8:e8";
    linkConfig.Name = "wireless";
  };
  systemd.network.links."10-ethernet" = {
    matchConfig.MACAddress = "b8:ca:3a:c8:30:f1";
    linkConfig.Name = "ethernet";
  };

  networking.hostName = "tv";
  networking.enableIPv6 = false;
  networking.wireless.enable = true;
  networking.wireless.interfaces = [ "wireless" ];
  networking.wireless.networks."L'internet de J et S".psk =
    (import ../secrets.nix).wireless.psk;
  networking.interfaces.ethernet.useDHCP = true;
  networking.interfaces.wireless.useDHCP = true;

  environment.systemPackages = with pkgs; [
    acpitool
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
    # disable internal bluetooth usb controller
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0cf3", ATTRS{idProduct}=="e004", ATTR{authorized}="0"
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

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.dbus.implementation = "broker";

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

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" "tty" "dialout" ];
  };

  users.users.git = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [
      ../identities/id_rsa_laptop.pub
      ../identities/id_rsa_oneplus.pub
      ../identities/id_rsa_tv.pub
    ];
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "900d";
    scrapeConfigs = [
      {
        job_name = "hass";
        scrape_interval = "1m";
        metrics_path =  "/api/prometheus";
        bearer_token = (import ../secrets.nix).hass.prometheus-token;
        static_configs = [
          { targets = [ "localhost:8123" ]; }
        ];
      }
    ];
  };

  custom = {
    dpi = 128;
    xserver.autoLogin = "guest";
    xserver.primaryOutput = "HDMI-1";
    home.root.cliTools.enable = true;
    home.guest.cliTools.enable = true;
    home.guest.guiTools.enable = true;
    home.guest.guiTools.autoLock = false;
    home.guest.guiTools.i3statusRustConfig = ./tv/i3status-rust.toml;
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 4 * * * guest git -C /etc/nixos pull --rebase"
    ];
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  system.stateVersion = "22.05";
}

