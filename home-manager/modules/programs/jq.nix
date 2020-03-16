{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.jq;

  colorType = mkOption {
    type = types.str;
    description = "ANSI color definition";
    example = "1;31";
    visible = false;
  };

  colorsType = types.submodule {
    options = {
      null = colorType;
      false = colorType;
      true = colorType;
      numbers = colorType;
      strings = colorType;
      arrays = colorType;
      objects = colorType;
    };
  };

in {
  options = {
    programs.jq = {
      enable = mkEnableOption "the jq command-line JSON processor";

      colors = mkOption {
        description = ''
          The colors used in colored JSON output.</para>

          <para>See <link xlink:href="https://stedolan.github.io/jq/manual/#Colors"/>.
        '';

        example = literalExample ''
          {
            null    = "1;30";
            false   = "0;31";
            true    = "0;32";
            numbers = "0;36";
            strings = "0;33";
            arrays  = "1;35";
            objects = "1;37";
          }
        '';

        default = {
          null = "1;30";
          false = "0;39";
          true = "0;39";
          numbers = "0;39";
          strings = "0;32";
          arrays = "1;39";
          objects = "1;39";
        };

        type = colorsType;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.jq ];

    home.sessionVariables = let c = cfg.colors;
    in {
      JQ_COLORS =
        "${c.null}:${c.false}:${c.true}:${c.numbers}:${c.strings}:${c.arrays}:${c.objects}";
    };
  };
}
