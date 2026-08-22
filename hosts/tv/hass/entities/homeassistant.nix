{ lib, config, ... }:

{
  config = {
    services.home-assistant.config = let
      device = {
          name = "Home Assistant";
          identifiers = [ "home_assistant_mqtt" ];
          connections = [[ "ip" "127.0.0.1" ]];
        };
    in {
      mqtt.sensor = [{
        name = "MQTT Ping";
        unique_id = "homeassistant_mqtt_ping";
        default_entity_id = "homeassistant_mqtt_ping";
        inherit device;
        device_class = "duration";
        entity_category = "diagnostic";
        state_topic = "homeassistant/ping";
        value_template = ''
          {% set ts_ping = as_timestamp(value, default=0) %}
          {% set ts_now = now().timestamp() %}
          {{ (ts_now - ts_ping) * 1000 }}
        '';
        unit_of_measurement = "ms";
      }];
      template = [
        {
          triggers = [{
            trigger = "state";
            entity_id = "sensor.homeassistant_mqtt_ping";
          }];
          binary_sensor = [{
            unique_id = "homeassistant_mqtt_connector";
            name = "MQTT connector";
            device_class = "connectivity";
            auto_off.minutes = 20;
            delay_on.seconds = 5;
            state = ''
              {% set ping = states('sensor.homeassistant_mqtt_ping') | int(default=9999) %}
              {% if ping < 1000 %}ON{% else %}OFF{% endif %}
            '';
          }];
        }
      ];
      "automation nixos" = [
        {
          alias = "Ping MQTT broker";
          mode = "restart";
          triggers = [
            {
              trigger = "homeassistant";
              event = "start";
            }
            {
              trigger = "time_pattern";
              minutes = "/15";
            }
          ];
          action = [{
            repeat = {
              while = [{
                condition = "template";
                value_template =
                  "{{ not is_state('binary_sensor.homeassistant_mqtt_connector', 'on') }}";
              }];
              sequence = [
                {
                  alias = "Backoff";
                  delay.milliseconds =
                    "{{ 200 ** (1 + ( repeat.index % 20 ) / 10) }}";
                }
                {
                  action = "mqtt.publish";
                  data = {
                    topic = "homeassistant/ping";
                    qos = 1;
                    payload = "{{ now() }}";
                  };
                }
              ];
            };
          }];
        }
      ];
    };
  };
}
