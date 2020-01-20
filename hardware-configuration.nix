# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/61055499-b643-4dcf-950d-16bf254e76b4";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3F35-DF16";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/5f39f059-b20d-4246-80b4-26122c8158ba";
      fsType = "ext4";
    };

  fileSystems."/docker" =
    { device = "/dev/disk/by-uuid/3c19e3d5-271c-4779-8e87-96778d3da7b5";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/110d4527-a772-4bac-b345-6826cf3a7e3c";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e622862d-dd96-46ea-a9b3-192a606b3bdd"; }
    ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
