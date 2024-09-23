{ pkgs, config, lib, ... }:

let
  channels = import ../pinned-channels;
  unstable = import channels.nixpkgs-unstable {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };
  };
  nur = import channels.nur-packages { inherit pkgs; };
in {

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.packageOverrides = pkgs: rec {
    inherit unstable;
    inherit nur;
  };

  nixpkgs.overlays = [
    (
      final: prev: {
        home-assistant = unstable.home-assistant;
        home-assistant-custom-components = unstable.home-assistant-custom-components // {
          ecoflowcloud = unstable.python312Packages.callPackage ./ha-custom-component-ecoflowcloud.nix { };
          livebox = unstable.callPackage ./ha-custom-component-livebox.nix {
            aiosysbus = unstable.python312Packages.callPackage ./python-lib-aiosysbus.nix { };
          };
          prixcarburant = unstable.callPackage ./ha-custom-component-prixcarburant.nix { };
        };
      }
    )
  ];
}
