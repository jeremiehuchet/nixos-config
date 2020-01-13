# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
    <nixos-hardware/lenovo/thinkpad/x1-extreme/gen2>
    ./hardware-configuration.nix
  ];

  hardware = {
    bumblebee.enable = true;
  };

  boot.earlyVconsoleSetup = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.systemd-boot.consoleMode = "max";
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
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="60:f2:62:15:55:db", NAME="wireless"
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

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    dfc
    git
    htop
    lm_sensors
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
    dpi = 192;
    libinput = {
      enable = true;
      accelSpeed = "0.5";
    };
  };

  users.users.jeremie = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "video" "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager.useUserPackages = true;
  home-manager.users.jeremie = import ./home.nix;

  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.maxJobs = 12;

  system.stateVersion = "19.09";

}

