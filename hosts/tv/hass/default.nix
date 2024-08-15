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
    customComponents = with pkgs.home-assistant-custom-components; [
      livebox
    #  prixcarburant
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
      mqtt = {
        sensor = let
          winky_id = "Winky-7F93B4";
          winky_defaults = {
            device = {
              name = "Winky";
              identifiers = [ "Winky-7F93B4" ];
              connections = [ ["mac" "8c:aa:b5:7f:93:b4"] ];
              sw_version = "V55";
              hw_version = "ESP8266";
            };
            expire_after = "3600";
            state_topic = "/xky-8c:aa:b5:7f:93:b4";
          };
        in [
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Energy";
            unique_id = "${winky_id}_energy";
            device_class = "energy";
            state_class = "total_increasing";
            value_template = "{{ value_json.BASE | int }}";
            unit_of_measurement = "Wh";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Mode";
            unique_id = "${winky_id}_mode";
            value_template = ''{{ value_json.ModeTic }}'';
            device_class = "enum";
            entity_category = "diagnostic";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Option Tarifaire";
            unique_id = "${winky_id}_optarif";
            value_template = ''{{ value_json.OPTARIF }}'';
            device_class = "enum";
            entity_category = "diagnostic";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Intensité souscrite";
            unique_id = "${winky_id}_isousc";
            state_class = "measurement";
            value_template = ''{{ value_json.ISOUSC | int }}'';
            unit_of_measurement = "A";
            device_class = "current";
            entity_category = "diagnostic";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Puissance apparente";
            unique_id = "${winky_id}_apower";
            value_template = ''{{ value_json.PAPP | int }}'';
            unit_of_measurement = "VA";
            device_class = "apparent_power";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Période tarifaire en cours";
            unique_id = "${winky_id}_ptec";
            value_template = ''{{ value_json.PTEC }}'';
            device_class = "enum";
            entity_category = "diagnostic";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Intensité instantanée";
            unique_id = "${winky_id}_iinst";
            state_class = "measurement";
            value_template = ''{{ value_json.IINST | int }}'';
            unit_of_measurement = "A";
            device_class = "current";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Intensité maximale";
            unique_id = "${winky_id}_imax";
            state_class = "measurement";
            value_template = ''{{ value_json.IMAX | int }}'';
            unit_of_measurement = "A";
            device_class = "current";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Groupe horaire";
            unique_id = "${winky_id}_hhphc";
            value_template = ''{{ value_json.HHPHC }}'';
            device_class = "enum";
            entity_category = "diagnostic";
         }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Mot d'état";
            unique_id = "${winky_id}_motdetat";
            value_template = ''{{ value_json.MOTDETAT }}'';
            device_class = "enum";
            entity_category = "diagnostic";
          }
          {
            inherit (winky_defaults) device expire_after state_topic;
            name = "Wifi signal";
            unique_id = "${winky_id}_rssi";
            state_class = "measurement";
            value_template = ''{{ value_json.RSSI | int }}'';
            device_class = "signal_strength";
            unit_of_measurement = "dBm";
            entity_category = "diagnostic";
          }
        ];
      };
      sensor = [
        {
          platform = "rest";
          #name = "Prix d'une palette de 975kg de pellets";
          name = "feedufeu_price_975kg"; # unique_id doesn't seem to work properly
          unique_id = "feedufeu_price_975kg";
          device_class = "monetary";
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
          unique_id = "feedufeu_price_";
          sensor = [
            {
              unique_id = "15kg";
              state = "{{ (states.sensor.feedufeu_price_975kg.state | float / 65) | round(2) }}";
              device_class = "monetary";
              icon = "mdi:currency-eur";
              picture = "https://www.feedufeu.com/images/logo.png";
              unit_of_measurement = "€";
            }
            {
              unique_id = "12kg";
              state = "{{ (states.sensor.feedufeu_price_15kg.state | float / 15 * 12) | round(2) }}";
              device_class = "monetary";
              icon = "mdi:currency-eur";
              picture = "https://www.feedufeu.com/images/logo.png";
              unit_of_measurement = "€";
            }
          ];
        }
      ];
      script = {
        create_winky_entities = let
          id = "Winky-7F93B4";
          mac = "8c:aa:b5:7f:93:b4";
        in {
          alias = "Create Winki device and entities";
          sequence = [
            {
              service = "mqtt.publish";
              data = {
                topic = "homeassistant/sensor/${id}/config";
                retain = true;
                payload = ''
                  {
                    "state_topic": "/xky-${mac}",
                    "name": "Energy",
                    "unique_id": "${id}-energy",
                    "device": {
                      "name": "Winky",
                      "model": "Winky {{ value_json.BoardVersion }}",
                      "manufacturer": "",
                      "identifiers": ["${id}"],
                      "connections": [ [ "mac", "${mac}" ] ],
                      "sw_version": "{{ value_json.FWVersion }}",
                      "hw_version": "{{ value_json.BoardVersion }}"
                    },
                    "device_class": "energy",
                    "expire_after": 600,
                    "state_class": "total_increasing",
                    "value_template": "{% raw %}{{ value_json.BASE | int }}{% endraw %}"
                  }
                '';
              };
            }
          ];
        };
      };
      "automation manual" = [
        {
          alias = "open covers weekdays";
          trigger = {
            platform = "sun";
            event = "sunrise";
            offset = "01:00:00";
          };
          condition = {
            condition = "time";
            weekday = ["fri" "thu" "wed" "tue" "mon"];
          };
          action = [{
            service = "cover.open_cover";
            entity_id = "cover.cover_ch4";
          }];
        }
        {
          alias = "close covers weekdays";
          trigger = {
            platform = "sun";
            event = "sunset";
            offset = "01:00:00";
          };
          condition = {
            condition = "time";
            weekday = ["fri" "thu" "wed" "tue" "mon"];
          };
          action = [{
            service = "cover.close_cover";
            entity_id = "cover.cover_ch4";
          }];
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
    logType = ["debug"];
    listeners = [{
      port = 1883;
      address = "0.0.0.0";
      users = {
        home-assistant = {
          acl = [
            "readwrite #"
            "readwrite homeassistant/status"
            "readwrite rika-firenet/#"
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
    wantedBy = ["multi-user.target"];
    environment = {
      RUST_LOG="info";
      MQTT_USERNAME = "mqtt-bridge";
      MQTT_PASSWORD = "123456";
      RIKA_USERNAME = secrets.home-automation.rika-username;
      RIKA_PASSWORD = secrets.home-automation.rika-password;
      #SOMFY_USERNAME = secrets.home-automation.somfy-username;
      #SOMFY_PASSWORD = secrets.home-automation.somfy-password;
      #SOMFY_CLIENT_ID = secrets.home-automation.somfy-client-id;
      #SOMFY_CLIENT_SECRET = secrets.home-automation.somfy-client-secret;
    };
    serviceConfig = {
      DynamicUser = "yes";
      ExecStart = "${pkgs.nur.hass-mqtt-bridge}/bin/hass-mqtt-bridge";
      Restart = "on-failure";
    };
  };
}
