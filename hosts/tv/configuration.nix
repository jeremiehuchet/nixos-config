# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../custom-pkgs
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
  networking.wireless.networks."L'internet de J".psk = (import ./secrets.nix).wireless.psk;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: rec {
    bazarr = pkgs.callPackage ./bazarr.nix { };
  };

  programs.vim.defaultEditor = true;

  environment = {
    systemPackages = with pkgs; [
      acpitool
      bazarr
      dmenu
      dunst
      gnupg
      lm_sensors
      mplayer
      ncdu
      dfc
      udiskie
      tree
      pass
      git google-chrome htop kodi nfs-utils terminator
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="usbhid", ATTR{../power/wakeup}="enabled"
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # boot.extraModprobeConfig = ''
  #   options snd_hda_intel enable=3
  # ''
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
  # hardware.pulseaudio.enable = true;

  fonts = {
    fonts = with pkgs; [
      nerdfonts
      noto-fonts
      emojione
    ];
    fontconfig.defaultFonts = {
      monospace =  [ "Noto Sans Mono Light" ];
      sansSerif = [ "Noto Sans" ];
      serif =  [ "Noto Serif" ];
    };
  };

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

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "fr";
    xkbOptions = "eurosign:e";
    libinput.enable = true;
    dpi = 140;

    desktopManager.default = "none";
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
    displayManager.auto.enable = true;
    displayManager.auto.user = "guest";
  };

  users.users.guest = {
    isNormalUser = true;
  };

  users.users.git = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [
      ../../identities/id_rsa_laptop.pub
      ../../identities/id_rsa_oneplus.pub
      ../../identities/id_rsa_tv.pub
    ];
  };

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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

