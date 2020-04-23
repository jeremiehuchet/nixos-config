{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
  secretsFile = ../secrets;
in {
  imports =
    [ ./laptop/hardware-configuration.nix ./common ../home ../custom-pkgs ];

  i18n.defaultLocale = "en_US.UTF-8";

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";

  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.extraModprobeConfig = ''
    # oled backlight
    options i915 enable_dpcd_backlight=1
    # audio power management
    options snd_hda_intel power_save=1
  '';
  boot.initrd.luks.devices.pv-enc-opened = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/var/lib/docker".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/var/lib/machines".options =
    [ "noatime" "nodiratime" "discard" ];
  fileSystems."/nix".options = [ "noatime" "nodiratime" "discard" ];

  powerManagement.powertop.enable = true;
  services.tlp.enable = true; # https://linrunner.de/en/tlp/tlp.html
  services.tlp.extraConfig = ''
    CPU_SCALING_GOVERNOR_ON_AC=powersave
    CPU_SCALING_GOVERNOR_ON_BAT=powersave
    CPU_HWP_ON_AC=balance_performance
    CPU_HWP_ON_BAT=balance_power
    CPU_MIN_PERF_ON_AC=17
    CPU_MAX_PERF_ON_AC=100
    CPU_MIN_PERF_ON_BAT=17
    CPU_MAX_PERF_ON_BAT=80
    CPU_BOOST_ON_AC=1
    CPU_BOOST_ON_BAT=0
    SCHED_POWERSAVE_ON_AC=0
    SCHED_POWERSAVE_ON_BAT=1
  '';
  services.throttled.enable = true; # https://github.com/erpalma/throttled

  systemd.tmpfiles.rules = [
    # remove internal ethernet device
    "w /sys/devices/pci0000:00/0000:00:1f.6/remove - - - - 1"
    # enable nvidia power management
    #"w /sys/bus/pci/devices/0000:01:00.0/power/control - - - - on"
    # disable wake-on-lan
    "w /sys/class/net/*/device/power/wakeup - - - - disabled"
  ];

  networking.hostName = "laptop";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    192.168.10.12 printer.oberthur.local
  '';

  console.font = "latarcyrheb-sun32";

  programs.light.enable = true;

  environment.systemPackages = with pkgs; [ btrfs-progs ];

  services.openssh.enable = true;

  security.pam.services.sudo.fprintAuth = true;
  services.fprintd.enable = true;
  services.fprintd.package = pkgs.fprintd-thinkpad;

  services.udev.extraRules = ''
    # network cards
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:f2:62:15:55:db", NAME="wireless"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:0e:c6:fe:5a:0c", NAME="aukey-ethernet"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="42:14:92:61:c6:70c", NAME="oneplus-usb"

    # critical battery level action
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-3]", RUN+="${pkgs.systemd}/bin/systemctl suspend"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[4-9]", RUN+="${pkgs.battery-alert}/bin/battery-alert $attr{capacity}"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[1-2][0-9]", RUN+="${pkgs.battery-alert}/bin/battery-alert $attr{capacity}"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[3-5][0-9]", RUN+="${pkgs.battery-alert}/bin/battery-alert $attr{capacity}"

    # Happlink (formerly Plug-Up) Security KEY
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0", TAG+="uaccess", GROUP="plugdev", MODE="0660"
  '';

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.startWhenNeeded = true;

  services.openvpn.servers.vpn0 = {
    authUserPass = secrets.vpn0.authUserPass;
    config = ''
      client
      dev tun
      proto udp
      remote ${secrets.vpn0.remoteIp} 1194
      pkcs12 ${secretsFile}/vpn0.p12
      auth-user-pass
      auth-nocache
      cipher AES-256-CBC
    '';
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  hardware.bluetooth.config.General.Enable = "Source,Sink,Media,Socket";
  services.blueman.enable = true;

  services.xserver = {
    videoDrivers = [ "nvidia" ];
    libinput = {
      enable = true;
      accelProfile = "flat";
      additionalOptions = ''
        Option "TransformationMatrix" "2.2 0 0 0 2.2 0 0 0 1"
      '';
      tappingDragLock = false;
    };
  };

  virtualisation.docker.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  users.users.jeremie = {
    isNormalUser = true;
    extraGroups =
      [ "docker" "lp" "networkmanager" "vboxusers" "video" "wheel" ];
  };

  custom = {
    dpi = 192;
    xserver.autoLogin = "jeremie";
    xserver.primaryOutput = "DP-2";
    home.root.cliTools.enable = true;
    home.jeremie.cliTools.enable = true;
    home.jeremie.guiTools.enable = true;
    home.jeremie.guiTools.i3statusRustConfig = ./laptop/i3status-rust.toml;
    home.jeremie.devTools.enable = true;
    m1.enable = true;
  };

  system.stateVersion = "20.03";
}
