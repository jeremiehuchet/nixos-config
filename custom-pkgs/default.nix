{ pkgs, config, ... }:

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
        home-assistant-custom-components = prev.home-assistant-custom-components // {
          livebox = pkgs.nur.hass-livebox-component;
          prixcarburant = pkgs.callPackage /home/guest/projects/nur-packages/pkgs/hass-prixcarburant-component {
            prixCarburantFrClient = pkgs.callPackage /home/guest/projects/nur-packages/pkgs/python-packages/prix-carburant-fr-client { };
          };
        };
      }
      )
  ];
}
