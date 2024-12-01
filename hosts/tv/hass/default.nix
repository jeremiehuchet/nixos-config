{ pkgs, ... }:

let
  secrets = import ../../../secrets.nix ;
in {

  imports = import ./entities;

  networking.firewall.allowedTCPPorts = [ 443 1883 ];

  services.nginx = {
    enable = true;
    virtualHosts."hass.huchet.ovh" = {
      serverAliases= ["hass.local.huchet.ovh"];
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

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraPackages = python3Packages: with python3Packages; [
      psycopg2
    ];
    extraComponents = [
      "default_config"

      "alert"
      "bluetooth" # use shelly bluetooth gateway instead?
      "bluetooth_le_tracker"
      "bthome"
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
      ecoflowcloud
      livebox
      prixcarburant
    ];
    config = {
      default_config = {};
      logger.default = "info";
      recorder.db_url = "postgresql://@/hass";
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
}
