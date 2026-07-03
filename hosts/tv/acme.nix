{ pkgs, ... }:

let
  secrets = import ../../secrets.nix;
in {
  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = secrets.acme.contactEmail;
      dnsProvider = secrets.acme.dnsProvider;
    };

    certs."huchet.ovh" = {
      domain = "huchet.ovh";
      extraDomainNames = [
        "grafana.huchet.ovh"
        "hass.huchet.ovh"
        "hass.local.huchet.ovh"
        "music.huchet.ovh"
        "office.huchet.ovh"
        "photos.huchet.ovh"
        "workspace.huchet.ovh"
        "vwar.huchet.ovh"
        "vwar.local.huchet.ovh"
      ];
      credentialFiles = {
        ACME_CREDENTIALS_HUCHET_OVH_FILE = pkgs.writeText "acme-credentials-huchet.ovh" secrets.acme.credentials."huchet.ovh";
      };
    };
  };
}
