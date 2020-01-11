# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
     <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
    ./hardware-configuration.nix
    ./home-manager/nixos
  ];

  boot.earlyVconsoleSetup = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.blacklistedKernelModules = [
    "nouveau" # See https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Extreme_(Gen_2)#Graphics
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.initrd.luks.devices = [ {
    name = "pv-enc-opened";
    device = "/dev/nvme0n1p2";
    preLVM = true;
    allowDiscards = true;
  } ];

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/nix".options = [ "noatime" "nodiratime" "discard" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="c6:d1:c1:15:11:f7", NAME="wireless"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="48:2a:e3:6b:11:0f", NAME="unknown"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:0e:c6:fe:5a:0c", NAME="aukey-ethernet"
  '';

  networking.hostName = "laptop";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
    fontconfig.defaultFonts = {
      emoji = [ "EmojiOne" ];
      monospace = [ "Noto Sans Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
    fonts = with pkgs; [
      noto-fonts
      emojione
      nerdfonts
    ];
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    dfc
    dunst
    gitFull
    google-chrome
    htop
    lm_sensors
    mplayer
    rofi
    terminator
    tree
    udiskie
    vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.light.enable = true;
  programs.vim.defaultEditor = true;

  services.openssh.enable = true;
  services.printing.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;
    layout = "fr";
    libinput.enable = true;
    dpi = 192;
    videoDrivers = [ "intel" "nvidia" ];

    windowManager.default = "i3";
    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
  };

  users.users.jeremie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "video" "wheel" ];
  };

  home-manager.users.jeremie = import ./home.nix;

  systemd.user.services."dunst" = {
    enable = true;
    description = "dunst for X11 notifications";
    wantedBy = [ "default.target" ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
  };

  systemd.user.services."udiskie" = {
    enable = true;
    description = "udiskie to automount removable media";
    wantedBy = [ "default.target" ];
    path = with pkgs; [
      gnome3.defaultIconTheme
      gnome3.gnome_themes_standard
      udiskie
    ];
    environment.XDG_DATA_DIRS="${pkgs.gnome3.defaultIconTheme}/share:${pkgs.gnome3.gnome_themes_standard}/share";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie -a -t -n -F ";
  };

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.maxJobs = 12;

  system.stateVersion = "19.09";

}

