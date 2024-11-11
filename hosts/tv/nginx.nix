{ pkgs, ... }:

{
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."default"= {
      default = true;
      rejectSSL = true;
      locations."/" = {
        return = "403 '<html><body>Forbidden</body></html>'";
        extraConfig = ''
          default_type text/html;
        '';
      };
    };
  };
}
