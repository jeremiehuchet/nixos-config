{ pkgs, ... }:

let
  secrets = import ../../../secrets.nix ;
in {

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
    extraPackages = python3Packages: with python3Packages; [
      psycopg2
    ];
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
      "tasmota"
    ];
    #customComponents = with pkgs.home-assistant-custom-components; [
    #  livebox
    #  prixcarburant
    #];
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
      mqtt = {
        sensor = [
          {
            name = "Energy";
            unique_id = "Winky-7F93B4";
            device_class = "energy";
            device = {
              name = "Winky";
              identifiers = [ "Winky-7F93B4" ];
              connections = [ ["mac" "8c:aa:b5:7f:93:b4"] ];
              sw_version = "V55";
            };
            expire_after = "120";
            state_class = "total_increasing";
            state_topic = "/xky-8c:aa:b5:7f:93:b4";
            value_template = "{{ value_json.BASE | int }}";
            unit_of_measurement = "Wh";
            json_attributes_topic = "/xky-8c:aa:b5:7f:93:b4";
          }
        ];
      };
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
      cover = [
        {
          platform = "template";
          covers = {
            garage_door = {
              device_class = "door";
              friendly_name = "Garage Door";
              unique_id = "OpenBK7231T-042BE1_cover";
              value_template = ''
                {% if states('binary_sensor.garagedoor_sensor') == 'off' %}
                  open
                {% else %}
                  closed
                {% endif %}
              '';
              open_cover = [
                {
                  condition = "state";
                  entity_id = "binary_sensor.garagedoor_sensor";
                  state = "on";
                }
                {
                  service = "switch.turn_on";
                  target.entity_id = "switch.garagedoor_button";
                }
              ];
              close_cover = [
                {
                  condition = "state";
                  entity_id = "binary_sensor.garagedoor_sensor";
                  state = "off";
                }
                {
                  service = "switch.turn_on";
                  target.entity_id = "switch.garagedoor_button";
                }
              ];
              stop_cover = [
                {
                  service = "switch.turn_on";
                  target.entity_id = "switch.garagedoor_button";
                }
              ];
              icon_template = ''
                {% if states('binary_sensor.garagedoor_sensor')=='off' %}
                  mdi:garage-open
                {% else %}
                  mdi:garage
                {% endif %}
              '';
            };
          };
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
            {
              name = "Apparent Power";
              state = ''{{ state_attr('sensor.winky_energy', 'PAPP') | int }}'';
              unit_of_measurement = "VA";
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
      ensureDBOwnership = true;
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
            "readwrite somfy-protect/#"
            "readwrite tasmota/#"
          ];
          password = "123456";
        };
        shelly = {
          acl = [
            "read homeassistant/status"
            "readwrite homeassistant/#"
            "readwrite shelly/#"
          ];
          password = "123456";
        };
        tasmota = {
          acl = [
            "read homeassistant/status"
            "readwrite homeassistant/#"
            "readwrite tasmota/#"
          ];
          password = "123456";
        };
        openbk = {
          acl = [
            "read homeassistant/status"
            "readwrite homeassistant/#"
            "readwrite openbk/#"
          ];
          password = "123456";
        };
        mqtt-bridge = {
          acl = [
            "read homeassistant/status"
            "readwrite homeassistant/#"
            "readwrite rika-firenet/#"
            "readwrite somfy-protect/#"
          ];
          password = "123456";
        };
        winky = {
          acl = [
            "readwrite #"
          ];
          password = secrets.home-automation.winky-password;
        };
      };
    }];
  };

  systemd.services.hass-mqtt-bridge = {
    description = "Home Assistant integrations MQTT bridge";
    after = [ "network.target" "mosquitto.service" ];
    wants = [ "mosquitto.service" ];
    environment = {
      RUST_LOG="info";
      MQTT_USERNAME = "mqtt-bridge";
      MQTT_PASSWORD = "123456";
      RIKA_USERNAME = secrets.home-automation.rika-username;
      RIKA_PASSWORD = secrets.home-automation.rika-password;
      SOMFY_USERNAME = secrets.home-automation.somfy-username;
      SOMFY_PASSWORD = secrets.home-automation.somfy-password;
      SOMFY_CLIENT_ID = secrets.home-automation.somfy-client-id;
      SOMFY_CLIENT_SECRET = secrets.home-automation.somfy-client-secret;
    };
    serviceConfig = {
      DynamicUser = "yes";
      ExecStart = "${pkgs.nur.hass-mqtt-bridge}/bin/hass-mqtt-bridge";
      Restart = "on-failure";
    };
  };
}
