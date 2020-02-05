# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
    <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
    ./hardware-configuration.nix
    ./custom-pkgs
  ];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.optimus_prime.enable = true;
  hardware.nvidia.optimus_prime.intelBusId = "PCI:0:2:0";
  hardware.nvidia.optimus_prime.nvidiaBusId = "PCI:1:0:0";

  boot.earlyVconsoleSetup = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #  boot.kernel.sysctl = {
  #    "kernel.nmi_watchdog" = 0;
  #    "vm.dirty_writeback_centisecs" = 6000;
  #  };
  boot.extraModprobeConfig = ''
    # oled backlight
    options i915 enable_dpcd_backlight=1
    # wifi power management
    options iwlmvm power_scheme=3
    options iwlwifi power_save=1
    # audio power management
    options snd_hda_intel power_save=1
  '';
  boot.cleanTmpDir = true;
  boot.initrd.luks.devices = [{
    name = "pv-enc-opened";
    device = "/dev/nvme0n1p2";
    preLVM = true;
    allowDiscards = true;
  }];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/docker".options = [ "noatime" "nodiratime" "discard" ];
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
    #"w /sys/class/net/*/device/power/wakeup - - - - disabled"
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:f2:62:15:55:db", NAME="wireless"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:0e:c6:fe:5a:0c", NAME="aukey-ethernet"
  '';

  networking.hostName = "laptop";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  security.sudo.extraConfig = "Defaults timestamp_timeout=10";

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "fr";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Paris";

  fonts = {
    enableFontDir = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fontconfig.dpi = 192;
    fonts = with pkgs; [ fira-code nerdfonts ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    dfc
    git
    hicolor-icon-theme
    htop
    kdeFrameworks.breeze-icons
    lm_sensors
    pretty-nixos-rebuild
    tree
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.light.enable = true;
  programs.vim.defaultEditor = true;
  programs.zsh.enable = true;

  services.kmscon.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  hardware.bluetooth.extraConfig = ''
    [General]
    Enable=Source,Sink,Media,Socket
  '';
  services.blueman.enable = true;

  services.xserver = {
    enable = true;
    layout = "fr";
    dpi = 192;
    videoDrivers = [ "nvidia" ];
    libinput = {
      enable = true;
      accelProfile = "flat";
      additionalOptions = ''
        Option "TransformationMatrix" "2.2 0 0 0 2.2 0 0 0 1"
      '';
      tappingDragLock = false;
    };
    displayManager.auto = {
      enable = true;
      user = "jeremie";
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  users.users.jeremie = {
    isNormalUser = true;
    extraGroups = [ "docker" "networkmanager" "vboxusers" "video" "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager.useUserPackages = true;
  home-manager.users.jeremie = import ./home;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;

  system.stateVersion = "19.09";

}

