{ lib, pkgs, config, ... }:

let
  cfg = config.services.backups;
  secrets = import ../secrets.nix;
  secretFiles = ../secrets;
in {

  options = with lib; {
    services.backups = mkOption {
      description = "Configures borg backups";
      type = types.attrsOf (types.submodule {
        options = {
          repository = mkOption {
            description = "Borg repository";
            type = types.str;
            example = "/var/backup";
          };
          database.postgresql = mkOption {
            description = "Backup a postgresql database (optional)";
            type = types.nullOr (types.submodule {
              options = {
                name = mkOption {
                  description = "The name of the database to dump";
                  type = types.str;
                  example = "mydatabase";
                };
              };
            });
            default = null;
          };
          paths = mkOption {
            description = "Paths to backup";
            type = types.listOf types.str;
            default = [];
            example = [ "/var/lib/nextcloud" ];
          };
        };
      });
      default = [];
    };
  };

  config = lib.mkIf (cfg != {}) {

    environment.systemPackages = [ pkgs.borgbackup ];

    services.borgmatic = {
      enable = true;
      configurations = lib.mapAttrs (name: opts: {
        repositories = [
          {
            label = name;
            path = opts.repository;
          }
        ];
        postgresql_databases = [
          {
            inherit (opts.database.postgresql) name;
            username = "postgres";
          }
        ];
        source_directories = opts.paths;
          progress = true;
          keep_within = "1d";
          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 6;
      }) cfg;
    };

  };
}
