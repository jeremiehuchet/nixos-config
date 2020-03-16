{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.xdg.mime;

in {
  options = {
    xdg.mime.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to install programs and files to support the
        XDG Shared MIME-info specification and XDG MIME Applications
        specification at
        <link xlink:href="https://specifications.freedesktop.org/shared-mime-info-spec/shared-mime-info-spec-latest.html"/>
        and
        <link xlink:href="https://specifications.freedesktop.org/mime-apps-spec/mime-apps-spec-latest.html"/>,
        respectively.
      '';
    };
  };

  config = mkIf config.xdg.mime.enable {
    home.packages = [
      # Explicitly install package to provide basic mime types.
      pkgs.shared-mime-info
    ];

    home.extraProfileCommands = ''
      if [[ -w $out/share/mime && -d $out/share/mime/packages ]]; then
        XDG_DATA_DIRS=$out/share \
        PKGSYSTEM_ENABLE_FSYNC=0 \
        ${pkgs.buildPackages.shared-mime-info}/bin/update-mime-database \
          -V $out/share/mime > /dev/null
      fi

      if [[ -w $out/share/applications ]]; then
        ${pkgs.buildPackages.desktop-file-utils}/bin/update-desktop-database \
          $out/share/applications
      fi
    '';
  };

}
