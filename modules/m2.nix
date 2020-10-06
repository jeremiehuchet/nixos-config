{ lib, pkgs, config, ... }:

{
  users.users.m2 = { shell = "/bin/nologin"; };
  systemd.services.m2-proxy-pac = let
    workdir = "/var/run/m2-nginx-proxy-pac";
    pidfile = "${workdir}/nginx.pid";
    webroot = pkgs.writeTextDir "proxy.pac"
      (builtins.readFile ../secrets/m2-proxy.pac);
    nginx-conf = pkgs.writeText "nginx.conf" ''
      user m2 nogroup;
      pid ${pidfile};
      daemon off;
      worker_processes  1;
      error_log stderr;
      events {
        worker_connections 8;
      }
      http {
        access_log stdout;
        server {
          listen 127.0.0.1:8080;
          location / {
            root ${webroot};
          }
        }
      }
    '';
    execCommand = "${pkgs.nginx}/bin/nginx -c ${nginx-conf} -p ${workdir}";
  in {
    description = "M2 proxy.pac http service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      ${pkgs.coreutils}/bin/mkdir -p ${workdir}
      ${pkgs.coreutils}/bin/chown m2: ${workdir}
      ${execCommand} -t
    '';
    serviceConfig = {
      Type = "simple";
      PIDFile = pidfile;
      ExecStart = execCommand;
      ExecReload =
        [ "${execCommand} -t" "${pkgs.coreutils}/bin/kill -HUP $MAINPID" ];
      ExecStop = "${pkgs.coreutils}/bin/kill -QUIT $MAINPID";
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
