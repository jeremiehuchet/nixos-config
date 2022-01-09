# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../common
      ../../home
      ../../custom-pkgs
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [
    "af_packet"
    "msr"
    "snd_hda_codec_hdmi"
    "snd_hda_codec_generic"
    "ledtrig_audio"
    "deflate"
    "efi_pstore"
    "pstore"
    "intel_rapl_msr"
    "mei_hdcp"
    "spi_pxa2xx_platform"
    "dw_dmac"
    "iTCO_wdt"
    "watchdog"
    "dw_dmac_core"
    "i2c_designware_platform"
    "8250_dw"
    "i2c_designware_core"
    "brcmfmac"
    "i915"
    "intel_rapl_common"
    "intel_pmc_core_pltdrv"
    "intel_pmc_core"
    "snd_soc_skl"
    "snd_soc_sst_ipc"
    "snd_soc_sst_dsp"
    "brcmutil"
    "snd_hda_ext_core"
    "snd_soc_acpi_intel_match"
    "snd_soc_acpi"
    "x86_pkg_temp_thermal"
    "intel_powerclamp"
    "snd_soc_core"
    "cec"
    "applesmc"
    "coretemp"
    "input_polldev"
    "mmc_core"
    "crct10dif_pclmul"
    "crc32_pclmul"
    "snd_compress"
    "ac97_bus"
    "nls_iso8859_1"
    "snd_pcm_dmaengine"
    "snd_hda_intel"
    "iptable_nat"
    "nls_cp437"
    "ghash_clmulni_intel"
    "drm_kms_helper"
    "nf_nat"
    "vfat"
    "rapl"
    "fat"
    "xt_conntrack"
    "cdc_ether"
    "intel_cstate"
    "snd_hda_codec"
    "nf_conntrack"
    "usbnet"
    "drm"
    "nf_defrag_ipv6"
    "nf_defrag_ipv4"
    "libcrc32c"
    "intel_uncore"
    "snd_hda_core"
    "cfg80211"
    "efivars"
    "ipt_rpfilter"
    "r8152"
    "thunderbolt"
    "snd_hwdep"
    "evdev"
    "mei_me"
    "joydev"
    "uas"
    "iptable_raw"
    "i2c_i801"
    "intel_gtt"
    "agpgart"
    "mii"
    "mousedev"
    "acpi_als"
    "mac_hid"
    "sbs"
    "i2c_algo_bit"
    "mei"
    "xt_pkttype"
    "rfkill"
    "nf_log_ipv4"
    "fb_sys_fops"
    "nf_log_common"
    "intel_lpss_pci"
    "syscopyarea"
    "sysfillrect"
    "intel_lpss"
    "sysimgblt"
    "xt_LOG"
    "idma64"
    "intel_xhci_usb_role_switch"
    "kfifo_buf"
    "i2c_core"
    "virt_dma"
    "roles"
    "sbshc"
    "xt_tcpudp"
    "industrialio"
    "sch_fq_codel"
    "iptable_filter"
    "snd_pcm_oss"
    "button"
    "applespi"
    "snd_mixer_oss"
    "video"
    "snd_pcm"
    "apple_bl"
    "ac"
    "backlight"
    "snd_timer"
    "snd"
    "soundcore"
    "loop"
    "cpufreq_powersave"
    "tun"
    "tap"
    "macvlan"
    "bridge"
    "stp"
    "llc"
    "kvm_intel"
    "kvm"
    "irqbypass"
    "efivarfs"
    "ip_tables"
    "x_tables"
    "autofs4"
    "atkbd"
    "libps2"
    "serio"
    "ext4"
    "crc32c_generic"
    "crc16"
    "mbcache"
    "jbd2"
    "dm_crypt"
    "sd_mod"
    "input_leds"
    "led_class"
    "hid_apple"
    "hid_generic"
    "usbhid"
    "hid"
    "usb_storage"
    "scsi_mod"
    "crc32c_intel"
    "xhci_pci"
    "xhci_hcd"
    "aesni_intel"
    "crypto_simd"
    "cryptd"
    "glue_helper"
    "usbcore"
    "nvme"
    "nvme_core"
    "usb_common"
    "rtc_cmos"
    "dm_snapshot"
    "dm_bufio"
    "dm_mod"
  ];
  boot.initrd.luks.devices.pv-enc = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
    allowDiscards = true;
  };

  hardware.enableRedistributableFirmware = true;

  networking.hostName = "nixbook";
  networking.enableIPv6 = false;
  networking.networkmanager.enable = true;

  systemd.network.links."10-wireless" = {
    matchConfig.MACAddress = "dc:a9:04:7d:6e:6c";
    linkConfig.Name = "wireless";
  };
  systemd.network.links."10-oneplus-usb" = {
    matchConfig.MACAddress = "42:14:92:61:c6:70";
    linkConfig.Name = "oneplus-usb";
  };

  systemd.tmpfiles.rules = [
    # 
    # see https://github.com/Dunedan/mbp-2016-linux/tree/3da5e3f#suspend--hibernation
    "w /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed - - - - 0"
    # disable wake-on-lan
    "w /sys/class/net/*/device/power/wakeup - - - - disabled"
  ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "fr";
  };

  services.kmscon.enable = true;
  services.openssh.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.startWhenNeeded = true;
  services.blueman.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

  sound.enable = true;

  virtualisation.docker.enable = true;

  services.xserver = {
    videoDrivers = [ "intel" ];
    libinput.enable = true;
    libinput.touchpad = {
      accelProfile = "adaptive";
      tappingDragLock = false;
    };
    xosdBatteryAlert.enable = true;
  };

  users.users.jeremie = {
    isNormalUser = true;
    extraGroups = [ "docker" "lp" "networkmanager" "vboxusers" "video" "wheel" ];
  };

  custom = {
    dpi = 128;
    xserver.autoLogin = "jeremie";
    xserver.primaryOutput = "DP-2";
    home.root.cliTools.enable = true;
    home.jeremie.cliTools.enable = true;
    home.jeremie.guiTools.enable = true;
    home.jeremie.guiTools.i3statusRustConfig = ./i3status-rust.toml;
    home.jeremie.devTools.enable = true;
  };

  system.stateVersion = "21.05";

}

