{ pkgs, ... }:

let
  minutes_to_seconds = minutes: minutes * 60;
in {
  services.fail2ban = {
    enable = true;
    banaction = "iptables-allports[blocktype=DROP]";
    banaction_allports = "iptables-allports[blocktype=DROP]";
    maxretry = 3;
    bantime = "1m";
    bantime-increment = {
      enable = true;
      rndtime = "67s";
      maxtime = "45d";
      #            1m 5m 30m 1h 6h 12h   1d    1w    4w
      multipliers = "1 5 30 60 360 720 1440 10080 40320";
      overalljails = true;
    };
    daemonSettings = {
      Definition = {
        logtarget = "SYSTEMD-JOURNAL";
      };
    };
    jails = {
      nginx-botsearch.settings = {
        # block IP address looking like a bot scanner more than 3 times overs 60s
        filter = "nginx-botsearch";
        logpath = "/var/log/nginx/access.log";
        maxretry = 3;
        findtime = 60;
      };
      nginx-bad-request.settings = {
        # block IP address issuing more than 10 Bad Requests in 5 minutes
        filter = "nginx-bad-request";
        logpath = "/var/log/nginx/access.log";
        maxretry = 10;
        findtime = minutes_to_seconds 5;
      };
      wireguard.settings = {
        enabled = true;
        filter = "wireguard";
        backend = "systemd";
        maxretry = 15;
        findtime = minutes_to_seconds 1;
      };
    };
  };

  systemd.tmpfiles.rules = [
    # enable wireguard debug logs
    "w /sys/kernel/debug/dynamic_debug/control - - - - module wireguard +p"
  ];

  environment.etc = {
    # Define filter that will detect wireguard handshake and packets errors
    "fail2ban/filter.d/wireguard.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
      [INCLUDES]

      before = common.conf

      [Definition]

      _daemon = kernel

      vpn_name = (?:[^:]+)
      peer_id = (?:\S+)
      vpn_ip_addr = (?:\S+)

      failregex = ^%(__prefix_line)swireguard: %(vpn_name)s: Invalid MAC of handshake, dropping packet from <HOST>.*\b
                  ^%(__prefix_line)swireguard: %(vpn_name)s: Invalid handshake initiation from <HOST>.*\b
                  ^%(__prefix_line)swireguard: %(vpn_name)s: Invalid handshake response from <HOST>.*\b
                  ^%(__prefix_line)swireguard: %(vpn_name)s: Packet has unallowed src IP %(vpn_ip_addr)s from peer %(peer_id)s .<HOST>.*\b
                  ^%(__prefix_line)swireguard: %(vpn_name)s: Packet is neither ipv4 nor ipv6 from peer %(peer_id)s .<HOST>.*\b
                  ^%(__prefix_line)swireguard: %(vpn_name)s: Packet has incorrect size from peer %(peer_id)s .<HOST>.*\b

      journalmatch = _TRANSPORT=kernel
    '');
  };
}
