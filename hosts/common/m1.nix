{ config, lib, pkgs, ... }:

let
  cfg = config.custom.m1;
  secrets = import ../../secrets.nix;
  secretFiles = ../../secrets;
in {

  options = { custom.m1.enable = lib.mkEnableOption "M1 tools"; };

  config = lib.mkIf cfg.enable {

    security.pki.certificates = [
      (builtins.readFile ../../secrets/m1-ca-1.crt)
      (builtins.readFile ../../secrets/m1-ca-2.crt)
    ];

    environment.etc."NetworkManager/dnsmasq.d/m1-dns-servers.conf".source =
      "${secretFiles}/m1-dnsmasq.conf";

    services.openvpn.servers.vpn1 = {
      config = ''
        client
        dev tun
        remote ${secrets.vpn1.remoteIp}
        pkcs12 ${secretFiles}/m1-vpn-cert.p12
        cipher AES-256-CBC
        lport 1195
        pull
      '';
    };

    environment.systemPackages = let
      gitConfig = pkgs.writeScriptBin "m1-git-config" ''
        #!/usr/bin/env bash
        set -e
        git config user.name "Jeremie Huchet"
        git config user.email "${secrets.m1.email}"
        cat - <<EOF
        $PWD
          remote.origin.url: $(git config remote.origin.url)
          user.name:         $(git config user.name)
          user.email:        $(git config user.email)
        EOF
      '';
      gitClone = pkgs.writeScriptBin "m1-git-clone" ''
        #!/usr/bin/env bash
        set -e
        dir=${secrets.m1.homedir}/$(sed -E 's/.*:(.*)\.git.*/\1/'<<< "$*")
        mkdir -p "$dir"
        git clone "$*" "$dir"
        (
          cd "$dir"
          ${gitConfig}/bin/m1-git-config
        )
      '';
    in [ gitConfig gitClone ];

  };
}
