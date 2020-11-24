{ lib, pkgs, config, ... }:

let
  cfg = config.custom.m2;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = { custom.m2.enable = lib.mkEnableOption "M2 tools"; };

  config = lib.mkIf cfg.enable {

    security.pki.certificates = [ (builtins.readFile "${secretFiles}/m2-ca.crt") ];

    system.activationScripts = {
      m2-ca-chrome = ''
        # FIXME: following script will fail if nssdb doesn't exist
        ${pkgs.nssTools}/bin/certutil -d sql:/home/jeremie/.pki/nssdb -A -n 'M1 CA' -i ${secretFiles}/m2-ca.crt -t TCP,TCP,TCP
      '';
    };

    systemd.services.m2-proxy-tunnel = {
      description = "M2 proxy access through SSH tunnel";
      after = [ "openvpn-m0.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "jeremie";
        ExecStart = ''
          ${pkgs.openssh}/bin/ssh -N -T \
              -o "ServerAliveInterval 10" \
              -o "ExitOnForwardFailure yes" \
              -L3128:${secrets.m2.proxy} \
              ${secrets.m2.ssh-gateway.user}@${secrets.m2.ssh-gateway.host}
        '';
        Restart = "on-failure";
      };
    };

    users.groups.m2 = { };
    users.users.m2-squid = {
      isSystemUser = true;
      group = "m2";
      home = "/var/cache/m2-squid";
      createHome = true;
    };
    users.users.m2-any-proxy = {
      isSystemUser = true;
      group = "m2";
      createHome = false;
    };

    #environment.etc."NetworkManager/dnsmasq.d/m2-dns.conf".text = ''
    #  server=/${secrets.m2.domain}/127.0.0.1#20053
    #'';

    systemd.services.m2-coredns = let
      templates = lib.mapAttrsToList (zone: regex: ''
        template IN A ${zone} {
          match ${regex}
          answer "{{ .Name }} 60 IN A 254.254.254.254"
          fallthrough
        }
      '') secrets.m2.regex-zones;
      configFile = pkgs.writeText "m2-coredns-config" ''
        . {
          bind 127.0.0.1

          forward . 127.0.0.1

          ${lib.concatStringsSep "\n" templates}
        }
      '';
    in {
      description = "M2 coredns dns server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        ExecStart =
          "${pkgs.coredns}/bin/coredns -dns.port 20053 -conf=${configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR1 $MAINPID";
        Restart = "on-failure";
      };
    };

    systemd.services.m2-squid = let
      squidConfig = pkgs.writeText "m2-squid.conf" ''
        # Uncomment for ACL debugging
        #debug_options 28,3

        http_access allow all

        http_port 127.0.0.1:23128
        http_port 127.0.0.1:23129 transparent

        acl localnet src 10.0.0.0/8     # RFC 1918 possible internal network
        acl localnet src 172.16.0.0/12  # RFC 1918 possible internal network
        acl localnet src 192.168.0.0/16 # RFC 1918 possible internal network
        acl localnet src 169.254.0.0/16 # RFC 3927 link-local (directly plugged) machines
        acl localnet src fc00::/7       # RFC 4193 local private network range
        acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

        acl SSL_ports port 443          # https
        acl Safe_ports port 80          # http
        acl Safe_ports port 21          # ftp
        acl Safe_ports port 443         # https
        acl Safe_ports port 70          # gopher
        acl Safe_ports port 210         # wais
        acl Safe_ports port 1025-65535  # unregistered ports
        acl Safe_ports port 280         # http-mgmt
        acl Safe_ports port 488         # gss-http
        acl Safe_ports port 591         # filemaker
        acl Safe_ports port 777         # multiling http
        acl CONNECT method CONNECT

        # Deny requests to certain unsafe ports
        http_access deny !Safe_ports

        # Deny CONNECT to other than secure SSL ports
        http_access deny CONNECT !SSL_ports

        # Only allow cachemgr access from localhost
        http_access allow localhost manager
        http_access deny manager

        # logs
        cache_log       stdio:/var/log/m2-squid/cache.log
        access_log      stdio:/var/log/m2-squid/access.log
        cache_store_log stdio:/var/log/m2-squid/store.log

        # Required by systemd service
        pid_filename    /run/m2-squid.pid

        # Run as user and group squid
        cache_effective_user m2-squid m2

        forwarded_for on

        # allow localhost to access the squid proxy
        http_access allow localhost
        # And finally deny all other access to this proxy
        #http_access deny all

        # Add any of your own refresh_pattern entries above these.
        refresh_pattern ^ftp:           1440    20%     10080
        refresh_pattern ^gopher:        1440    0%      1440
        refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
        refresh_pattern .               0       20%     4320

        shutdown_lifetime 1 seconds
      '';
    in {
      description = "M2 squid proxy server";
      after = [ "network.target" ];
      wants = [ "m2-coredns.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        PIDFile = "/run/m2-squid.pid";
        ExecStart = "${pkgs.squid}/bin/squid -YCs -f ${squidConfig}";
        Restart = "on-failure";
      };
    };

    systemd.services.m2-any-proxy = let
      iptables = "${pkgs.iptables}/bin/iptables";
      preStart = pkgs.writeScriptBin "m2-any-proxy-pre-start" ''
        #!${pkgs.stdenv.shell}
        # drop existing rules
        ${iptables} -t nat -D OUTPUT -p tcp -j REDSOCKS || true
        ${iptables} -t nat -F REDSOCKS || true
        ${iptables} -t nat -X REDSOCKS || true
        # setup rules
        ${iptables} -t nat -N REDSOCKS
        ${iptables} -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
        ${iptables} -t nat -A REDSOCKS -p tcp -m owner --gid-owner m2 -j RETURN
        ${iptables} -t nat -A REDSOCKS -p tcp --match multiport --dports 80,8080 -j REDIRECT --to-ports 23129
        ${iptables} -t nat -A REDSOCKS -p tcp --match multiport --dports 443 -j REDIRECT --to-ports 23130
      '';
      postStart = pkgs.writeScriptBin "m2-any-proxy-post-start" ''
        #!${pkgs.stdenv.shell}
        ${iptables} -t nat -A OUTPUT -p tcp -j REDSOCKS
      '';
      preStop = pkgs.writeScriptBin "m2-any-proxy-pre-stop" ''
        #!${pkgs.stdenv.shell}
        ${iptables} -t nat -D OUTPUT -p tcp -j REDSOCKS
        ${iptables} -t nat -F REDSOCKS
        ${iptables} -t nat -X REDSOCKS
      '';
    in {
      description = "M2 any-proxy transparent proxy relay server";
      after = [ "network.target" ];
      wants = [ "m2-squid.service" ];
      #wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "m2-any-proxy";
        Group = "m2";
        ExecStartPre = "+${preStart}/bin/m2-any-proxy-pre-start";
        ExecStartPost = "+${postStart}/bin/m2-any-proxy-post-start";
        ExecStopPre = "+${preStop}/bin/m2-any-proxy-pre-stop";
        ExecStart = "${pkgs.nur.any-proxy}/bin/any-proxy -l 127.0.0.1:23130 -p 127.0.0.1:23128 -f /var/log/m2-any-proxy/any-proxy.log -v=1";
        Restart = "on-failure";
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/log/m2-any-proxy 0775 m2-any-proxy m2 - -"
      "d /var/log/m2-squid 0775 m2-squid m2 - -"
    ];

  };
}
