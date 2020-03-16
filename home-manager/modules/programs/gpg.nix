{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.gpg;

  cfgText =
    concatStringsSep "\n"
    (attrValues
    (mapAttrs (key: value:
      if isString value
      then "${key} ${value}"
      else optionalString value key)
    cfg.settings));

in {
  options.programs.gpg = {
    enable = mkEnableOption "GnuPG";

    settings = mkOption {
      type = types.attrsOf (types.either types.str types.bool);
      example = {
        no-comments = false;
        s2k-cipher-algo = "AES128";
      };
      description = ''
        GnuPG configuration options. Available options are described
        in the gpg manpage:
        <link xlink:href="https://gnupg.org/documentation/manpage.html"/>.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.gpg.settings = {
      personal-cipher-preferences = mkDefault "AES256 AES192 AES";
      personal-digest-preferences = mkDefault "SHA512 SHA384 SHA256";
      personal-compress-preferences = mkDefault "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = mkDefault "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = mkDefault "SHA512";
      s2k-digest-algo = mkDefault "SHA512";
      s2k-cipher-algo = mkDefault "AES256";
      charset = mkDefault "utf-8";
      fixed-list-mode = mkDefault true;
      no-comments = mkDefault true;
      no-emit-version = mkDefault true;
      keyid-format = mkDefault "0xlong";
      list-options = mkDefault "show-uid-validity";
      verify-options = mkDefault "show-uid-validity";
      with-fingerprint = mkDefault true;
      require-cross-certification = mkDefault true;
      no-symkey-cache = mkDefault true;
      use-agent = mkDefault true;
    };

    home.packages = [ pkgs.gnupg ];

    home.file.".gnupg/gpg.conf".text = cfgText;
  };
}
