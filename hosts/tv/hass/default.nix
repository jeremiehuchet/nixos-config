{ config, pkgs, ... }:

let
  secrets = import ../../../secrets.nix ;
in {
  imports = [
    ./entities/covers.nix
    ./entities/edf-prices.nix
    ./entities/garage_door.nix
    ./entities/homeassistant.nix
    ./entities/shelly.nix
    ./entities/winky.nix
  ];

  config = {

    networking.firewall.allowedTCPPorts = [ 443 1883 ];

    services.nginx = {
      enable = true;
      virtualHosts."hass.huchet.ovh" = {
        serverAliases= ["hass.iot"];
        useACMEHost = "huchet.ovh";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };
    };

    systemd.tmpfiles.rules = [
      "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    ];

    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraPackages = python3Packages: with python3Packages; [
        aioesphomeapi
        universal-silabs-flasher
        psycopg2
      ];
      extraComponents = [
        "default_config"
        "zha" # unused but required at startup to avoid loading error

        "alert"
        "bluetooth" # use shelly bluetooth gateway instead?
        "bluetooth_le_tracker"
        "bthome"
        "esphome"
        "homekit_controller"
        "influxdb"
        "linux_battery"
        "meteo_france"
        "mobile_app"
        "mqtt"
        "open_meteo"
        "prometheus"
        "rest"
        "roborock"
        "shelly"
        "signal_messenger"
        "sun"
        "tasmota"
      ];
      customComponents = with pkgs.home-assistant-custom-components; [
        #ecoflowcloud
        livebox
        prixcarburant
        rtetempo
      ];
      config = {
        default_config = {};
        logger.default = "info";
        recorder = {
          db_url = "postgresql://@/hass";
          commit_interval = 30;
          purge_keep_days = 10;
        };
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
          server_host = "127.0.0.1";
          trusted_proxies = [ "127.0.0.1" ];
          use_x_forwarded_for = true;
          ip_ban_enabled = true;
          login_attempts_threshold = 5;
        };
        "automation ui" = "!include automations.yaml"; 
        influxdb = {
          api_version = 2;
          host = "127.0.0.1";
          port = 8086;
          ssl = false;
          token = secrets.influxdb.hass_app_token;
          organization = "home";
          bucket = "hass";
          max_retries = 2;
          tags_attributes = [ "friendly_name" ];
        };
        prometheus.filter.include_domains = [
          "persistent_notification"
          "sensor"
          "sun"
        ];
        device_tracker = [
          { platform = "bluetooth_le_tracker"; }
        ];
        sensor = [
          { platform = "linux_battery"; }
          {
             platform = "prix_carburant";
             stations = secrets.home-automation.fuel-stations;
          }
        ];
        rest = [
          {
            resource = "https://www.feedufeu.com/fdf-bo/includes/getPrice.php?dep=35&qte=1";
            # example response: 396.50€<span>TTC</span><br><span>396.50€/palette</span> 
            scan_interval = 86400; # seconds or 1 day
            sensor = [ 
              {
                name = "feedufeu_price_975kg";
                unique_id = "feedufeu_price_975kg";
                value_template = "{{ value | regex_replace(find='€.*', replace='') | float }}";
                state_class = "measurement";
                icon = "mdi:currency-eur";
                unit_of_measurement = "€";
              }
              {
                name = "feedufeu_price_15kg";
                unique_id = "feedufeu_price_15kg";
                value_template = "
                  {% set prix_65_sacs_15kg = value | regex_replace(find='€.*', replace='') | float %}
                  {{ prix_65_sacs_15kg / 65 | round(2) }}
                ";
                state_class = "measurement";
                icon = "mdi:currency-eur";
                unit_of_measurement = "€";
              }
              {
                name = "feedufeu_price_1kg";
                unique_id = "feedufeu_price_1kg";
                value_template = "
                  {% set prix_65_sacs_15kg = value | regex_replace(find='€.*', replace='') | float %}
                  {{ prix_65_sacs_15kg / 65 / 15 | round(2) }}
                ";
                state_class = "measurement";
                icon = "mdi:currency-eur";
                unit_of_measurement = "€";
              }
            ];
          }
        ];
        template = [
          {
            unique_id = "garage_door_";
            binary_sensor = [
              {
                unique_id = "opened_at_night";
                state = ''{{ not is_state("cover.garage_door", "closed") and (today_at("21:00") < now() or now() < today_at('7:30')) }}'';
                device_class = "safety";
              }
              {
                unique_id = "opened_but_nobody_at_home";
                state = ''{{ not is_state("cover.garage_door", "closed") and not is_state('person.jeremie','home') }}'';
                device_class = "safety";
              }
            ];
            sensor = [
              {
                unique_id = "optimistic_state";
                device_class = "enum";
                state = ''
                  {% if is_state('binary_sensor.garagedoor_sensor', 'off') %}
                    CLOSED
                  {% elif is_state('binary_sensor.garagedoor_sensor', 'on') %}
                    {% if as_timestamp(now()) - as_timestamp(states.switch.garagedoor_button.last_changed) > 16 %}
                      OPENED
                    {% else %}
                      OPENING or CLOSING
                    {% endif %}
                  {% else %}
                    unknown
                  {% endif %}
                '';
              }
            ];
          }
        ];
        alert = {
          garage_door_open_at_night = {
            name = "Garage is open at night";
            done_message = "clear_notification";
            entity_id = "binary_sensor.garage_door_opened_at_night";
            repeat = 15;
            can_acknowledge = true;
            skip_first = true;
            notifiers = [ "mobile_app_jeremie" ];
            data = {
              tag = "garage-door";
            };
          };
          garage_door_open_but_nobody_at_home = {
            name = "Garage is open but nobody at home";
            done_message = "clear_notification";
            entity_id = "binary_sensor.garage_door_opened_but_nobody_at_home";
            repeat = 5;
            can_acknowledge = true;
            skip_first = false;
            notifiers = [ "mobile_app_jeremie" ];
            data = {
              tag = "garage-door";
            };
          };
        };
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
      #logType = ["debug"];
      listeners = [{
        port = 1883;
        address = "0.0.0.0";
        users = {
          home-assistant = {
            acl = [
              "readwrite #"
              "readwrite homeassistant/status"
              "readwrite rika-firenet/#"
              "readwrite shellies/command"
              "readwrite shelly/#"
              "readwrite somfy-protect/#"
              "readwrite tasmota/#"
            ];
            password = secrets.home-automation.mosquitto.hass.password;
          };
          shelly = {
            acl = [
              "read homeassistant/status"
              "read shellies/command"
              "readwrite homeassistant/#"
              "readwrite shelly/#"
            ];
            password = secrets.home-automation.mosquitto.shelly.password;
          };
          tasmota = {
            acl = [
              "read homeassistant/status"
              "readwrite homeassistant/#"
              "readwrite tasmota/#"
            ];
            password = secrets.home-automation.mosquitto.tasmota.password;
          };
          openbk = {
            acl = [
              "read homeassistant/status"
              "readwrite homeassistant/#"
              "readwrite openbk/#"
            ];
            password = secrets.home-automation.mosquitto.openbk.password;
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
              "readwrite energy/xky-8c:aa:b5:7f:93:b4"
            ];
            password = secrets.home-automation.winky-password;
          };
          zigbee2mqtt = {
            acl = [
              "read homeassistant/status"
              "readwrite homeassistant/#"
              "readwrite zigbee2mqtt/#"
            ];
            password = "123456";
          };
        };
      }];
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        version = 4;
        mqtt = {
          server = "mqtt://localhost:1883";
          base_topic = "zigbee2mqtt";
          user = "zigbee2mqtt";
          password = "123456";
          client_id = "zigbee2mqtt";
          include_device_information = true;
          version = 5;
        };
        serial = {
          port = "/dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_8a83b1e1833aef11a469281455516304-if00-port0";
          adapter = "ember";
          baudrate = 115200;
        };
        advanced = {
          log_level = "warn";
          channel = 11;
          network_key = secrets.home-automation.zigbee.network_key;
          last_seen = "ISO_8601";
          output = "json";
        };
        availability = {
          enabled = true;
        };
        homeassistant = {
          enabled = true;
          discovery_topic = "homeassistant";
          status_topic = "homeassistant/status";
          experimental_event_entities = false;
          legacy_action_sensor = false;
        };
        frontend = {
          enable = true;
          host = "0.0.0.0";
          port = 8081;
        };
      };
    };

    systemd.services.hass-mqtt-bridge = {
      description = "Home Assistant integrations MQTT bridge";
      after = [ "network.target" "mosquitto.service" ];
      wants = [ "mosquitto.service" ];
      wantedBy = ["multi-user.target"];
      environment = {
        RUST_LOG="info,hass_mqtt_bridge::rika=trace";
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

  };
}
