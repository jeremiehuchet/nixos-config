{ pkgs, ... }:

let
  secrets = import ../../../secrets.nix ;
in {

  disabledModules = [
    "services/home-automation/home-assistant.nix"
  ];

  networking.firewall.allowedTCPPorts = [ 80 1883 ];

  services.nginx = {
    enable = true;
    virtualHosts."hass.ignorelist.com" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123/";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    package =
      (pkgs.home-assistant.override {
        extraPackages = py: with py; [
          psycopg2
        ];
      })
      .overrideAttrs (oldAttrs: {
        doInstallCheck = false;
      });
    extraComponents = [
      "default_config"

      "bluetooth"
      "bluetooth_le_tracker"
      "bthome"
      "meteo_france"
      "mobile_app"
      "mqtt"
      "open_meteo"
      "prometheus"
      "rest"
      "signal_messenger"
      "sun"
    ];
    config = {
      default_config = {};
      logger.default = "info";
      homeassistant = let
        homeSecrets = (import ../../../secrets.nix).home;
      in {
        name = "Home";
        country = "FR";
        longitude = homeSecrets.longitude;
        latitude = homeSecrets.latitude;
        temperature_unit = "C";
        time_zone = "Europe/Paris";
        unit_system = "metric";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
        ip_ban_enabled = true;
        login_attempts_threshold = 5;
      };
      bluetooth = {};
      prometheus.filter.include_domains = [
        "persistent_notification"
        "sensor"
        
        "sun"
      ];
      device_tracker = [
        {
          platform = "bluetooth_le_tracker";
        }
      ];
      sensor = [
        {
          platform = "rest";
          name = "Prix d'une palette de pellets";
          unique_id = "feedufeu_one_pellet_pallet_price";
          state_class = "measurement";
          icon = "mdi:currency-eur";
          picture = "https://www.feedufeu.com/images/logo.png";
          unit_of_measurement = "€";
          resource = "https://www.feedufeu.com/fdf-bo/includes/getPrice.php?dep=35&qte=1";
          value_template = "{{ value | regex_replace(find='€.*', replace='') }}";
          scan_interval = 86400; # seconds or 1 day
          force_update = true;
        }
      ];
      template = [
        {
          sensor = [
            {
              name = "Prix d'un sac de 15kg de pellets";
              unique_id = "feedufeu_16kg_pellet_price";
              state = "{{ states.sensor.prix_d_une_palette_de_pellets.state | float / 65 }}";
              state_class = "measurement";
              icon = "mdi:currency-eur";
              picture = "https://www.feedufeu.com/images/logo.png";
              unit_of_measurement = "€";
            }
          ];
        }
      ];
      recorder.db_url = "postgresql://@/hass";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };

  services.mosquitto = {
    enable = true;
    listeners = [{
      port = 1883;
      address = "0.0.0.0";
      users = {
        home-assistant = {
          acl = [
            "read #"
            "readwrite homeassistant/status"
            "readwrite shelly/#"
          ];
          password = "123456";
        };
        shelly = {
          acl = [
            "readwrite shelly/#"
            "readwrite homeassistant/#"
          ];
          password = "123456";
        };
        mqtt-bridge = {
          acl = ["readwrite homeassistant/#"];
          password = "123456";
        };
      };
    }];
  };
}
