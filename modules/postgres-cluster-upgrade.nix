{ lib, pkgs, config, ... }:

let
  cfg = config.programs.upgrade-pg-cluster;
in {

  options.programs.upgrade-pg-cluster = with lib; {
    enable = mkEnableOption "Configure ad block list in dnsmasq";
    newPostgres = mkOption {
      description = "The postgresql package of the target version to migrate to.";
      type = types.package;
      example = pkgs.postgresql_18;
    };
    shared_preload_libraries = mkOption {
      description = "List of libraries to be preloaded.";
      type = types.nullOr (types.listOf types.str);
      example = [ "auto_explain" "anon" ];
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      (
        let
          pgCfg = config.services.postgresql;
          shared_preload_libraries = builtins.concatStringsSep "," cfg.shared_preload_libraries;
        in
        pkgs.writeScriptBin "upgrade-pg-cluster" ''
          set -eux
          # XXX it's perhaps advisable to stop all services that depend on postgresql
          systemctl stop postgresql

          export NEWDATA="/var/lib/postgresql/${cfg.newPostgres.psqlSchema}"
          export NEWBIN="${cfg.newPostgres}/bin"
  
          export OLDDATA="${pgCfg.dataDir}"
          export OLDBIN="${pgCfg.finalPackage}/bin"
  
          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          cd "$NEWDATA"
          sudo -u postgres "$NEWBIN/initdb" -D "$NEWDATA" ${lib.escapeShellArgs pgCfg.initdbArgs}
  
          sudo -u postgres "$NEWBIN/pg_upgrade" \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir "$OLDBIN" --new-bindir "$NEWBIN" \
            -O "-c shared_preload_libraries=${shared_preload_libraries}"
            "$@"
        ''
      )
    ];

  };
}
