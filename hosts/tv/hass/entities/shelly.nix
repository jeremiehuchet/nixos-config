{ lib, pkgs, config, ... }:

let
  covers = {
    kitchen = {
      name = "Cover kitchen";
      topic_folder = "cover-kitchen";
      travelling_time_up = 15;
      travelling_time_down = 15;
    };
    dining_room = {
      name = "Cover dining room";
      topic_folder = "cover-dining-room";
      travelling_time_up = 30;
      travelling_time_down = 25;
    };
    living_room = {
      name = "Cover living room";
      topic_folder = "cover-living-room";
      travelling_time_up = 25;
      travelling_time_down = 25;
    };
  };

  slugify = string:
    lib.toLower (builtins.replaceStrings [ " " ] [ "_" ] string);
  rawTemplate = string: "{% raw %}${string}{% endraw %}";

in {

  config = {
    services.home-assistant.config = {
      script = {
        shelly_broadcast_command = {
          alias = "Shelly broadcast command";
          icon = "mdi:bullhorn";
          description =
            "Publish a command to Shelly MQTT broadcast topic to notify all devices";
          fields = {
            command = {
              description = "The command to broadcast";
              example = "status_update";
              required = true;
              selector.select.options = [ "announce" "status_update" ];
            };
          };
          sequence = [{
            action = "mqtt.publish";
            data = {
              topic = "shellies/command";
              payload = "{{ command }}";
              qos = "1";
            };
          }];
        };
        shelly_publish_cover_config = {
          alias = "Shelly publish Cover MQTT config";
          icon = "mdi:cog-play";
          description =
            "Publish an MQTT message with the configuration to control a cover device";
          mode = "parallel";
          fields = {
            id = {
              description = "The device id";
              example = "shellyplus2pm-A6DC121B3EA5";
            };
            name = {
              description = "The cover name";
              example = "Kitchen shutter";
            };
            model = {
              description = "The device model";
              example = "Shelly Plus 2PM (SNSW-102P16EU)";
            };
            hw_version = {
              description = "The device hardware version";
              example = "gen2";
            };
            sw_version = {
              description = "The device software version";
              example = "20250924-062729/1.7.1-gd336f31";
            };
            mac = {
              description = "The device MAC address";
              example = "A6:DC:12:1B:3E:A5";
            };
          };
          sequence = let
            device_name_slug =
              "{{ name | lower | regex_replace(find='[^a-zA-Z0-9-_]+', replace='-') }}";
            baseTopic = "shelly/${device_name_slug}";
            common_entity_attributes = {
              origin.name = "Home Assistant configuration";
              device = {
                connections = [[ "mac" "{{ mac }}" ]];
                hw_version = "{{ hw_version }}";
                identifiers = [ "{{ id }}" ];
                manufacturer = "Shelly";
                model = "{{ model }}";
                name = "{{ name }}";
                sw_version = "{{ sw_version }}";
              };
              availability = [{
                topic = "${baseTopic}/online";
                payload_available = "true";
                payload_not_available = "false";
              }];
              qos = 2;
            };
          in builtins.map (entity: {
            action = "mqtt.publish";
            data = {
              topic =
                "homeassistant/${entity.platform}/${device_name_slug}-{{ id }}${entity.topic-suffix}/config";
              retain = true;
              qos = 1;
              payload =
                builtins.toJSON (common_entity_attributes // entity.attributes);
            };
          }) ([
            {
              platform = "cover";
              topic-suffix = "";
              attributes = {
                unique_id = "{{ id }}";
                default_entity_id = "${device_name_slug}";
                device_class = "shutter";
                payload_close = "close";
                payload_open = "open";
                payload_stop = "stop";
                command_topic = "${baseTopic}/command/cover:0";
                position_closed = 0;
                position_open = 100;
                position_template =
                  rawTemplate "{{ value_json.current_pos | int }}";
                position_topic = "${baseTopic}/status/position";
                state_closed = "closed";
                state_closing = "closing";
                state_open = "open";
                state_opening = "opening";
                state_stopped = "stopped";
                state_topic = "${baseTopic}/status/cover:0";
                value_template = rawTemplate "{{ value_json.state }}";
              };
            }
            {
              platform = "binary_sensor";
              topic-suffix = "-cloud";
              attributes = {
                name = "Shelly cloud";
                unique_id = "{{ id }}-cloud";
                default_entity_id = "${device_name_slug}_cloud";
                device_class = "connectivity";
                entity_category = "diagnostic";
                state_topic = "${baseTopic}/status/cloud";
                value_template = rawTemplate
                  "{% if value_json.connected == 'true' %}ON{% else %}OFF{% endif %}";
              };
            }
            {
              platform = "sensor";
              topic-suffix = "-rssi";
              attributes = {
                unique_id = "{{ id }}-rssi";
                default_entity_id = "${device_name_slug}_rssi";
                device_class = "signal_strength";
                name = "RSSI";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "${baseTopic}/status/wifi";
                value_template = rawTemplate "{{ value_json.rssi | int }}";
                unit_of_measurement = "dBm";
              };
            }
            {
              platform = "sensor";
              topic-suffix = "-uptime";
              attributes = {
                unique_id = "{{ id }}-uptime";
                default_entity_id = "${device_name_slug}_uptime";
                device_class = "duration";
                name = "Uptime";
                entity_category = "diagnostic";
                state_class = "total_increasing";
                state_topic = "${baseTopic}/status/sys";
                value_template = rawTemplate "{{ value_json.uptime | int(0) }}";
                unit_of_measurement = "s";
              };
            }
          ]

            ++ (builtins.map (metric_prefix: {
              platform = "sensor";
              topic-suffix = "-${metric_prefix}_size";
              attributes = {
                name = "${metric_prefix} size";
                unique_id = "{{ id }}-${metric_prefix}_size";
                default_entity_id = "${device_name_slug}_${metric_prefix}_size";
                device_class = "data_size";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "${baseTopic}/status/sys";
                value_template =
                  rawTemplate "{{ value_json.${metric_prefix}_size | int }}";
                unit_of_measurement = "B";
              };
            }) [ "fs" "ram" ])

            ++ (builtins.map (metric_prefix: {
              platform = "sensor";
              topic-suffix = "-${metric_prefix}_used";
              attributes = {
                name = "${metric_prefix} used";
                unique_id = "{{ id }}-${metric_prefix}_used";
                default_entity_id = "${device_name_slug}_${metric_prefix}_used";
                device_class = "data_size";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "${baseTopic}/status/sys";
                value_template = rawTemplate
                  "{{ (value_json.${metric_prefix}_size | int) - (value_json.${metric_prefix}_free | int) }}";
                unit_of_measurement = "B";
              };
            }) [ "fs" "ram" ])

            ++ (builtins.map (metric_prefix: {
              platform = "sensor";
              topic-suffix = "-${metric_prefix}_used";
              attributes = {
                name = "${metric_prefix} used";
                unique_id = "{{ id }}-${metric_prefix}_used";
                default_entity_id = "${device_name_slug}_${metric_prefix}_used";
                device_class = "data_size";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "${baseTopic}/status/sys";
                value_template = rawTemplate
                  "{{ (value_json.${metric_prefix}_size | int) - (value_json.${metric_prefix}_free | int) }}";
                unit_of_measurement = "B";
              };
            }) [ "fs" "ram" ])

            ++ [{
              platform = "sensor";
              topic-suffix = "-ram_max_used";
              attributes = {
                name = "ram_max used";
                unique_id = "{{ id }}-ram_max_used";
                default_entity_id = "${device_name_slug}_ram_max_used";
                device_class = "data_size";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "${baseTopic}/status/sys";
                value_template = rawTemplate
                  "{{ (value_json.ram_size | int) - (value_json.ram_min_free | int) }}";
                unit_of_measurement = "B";
              };
            }]
          );
        };
      };
      "automation manual" = [
        {
          alias = "Shelly broadcast 'announce' on start and once a day";
          triggers = [
            {
              trigger = "state";
              entity_id = "binary_sensor.mqtt_connector";
              to = "on";
            }
            {
              trigger = "time";
              at = "05:00:00";
            }
          ];
          action = [{
            action = "script.shelly_broadcast_command";
            data.command = "announce";
          }];
        }
        {
          alias = "Shelly broadcast 'status_update' periodically";
          triggers = [
            {
              trigger = "state";
              entity_id = "binary_sensor.mqtt_connector";
              to = "on";
            }
            {
              trigger = "time_pattern";
              minutes = "/5";
            }
          ];
          action = [{
            action = "script.shelly_broadcast_command";
            data.command = "status_update";
          }];
        }
        {
          alias = "Publish shelly config and state on device announcement";
          mode = "parallel";
          triggers = lib.mapAttrsToList (id: config: {
            trigger = "mqtt";
            topic = "shelly/+/announce";
          }) covers;
          action = [
            {
              action = "script.shelly_publish_cover_config";
              data = {
                id = "{{ trigger.payload_json.id }}";
                name = "{{ trigger.payload_json.name }}";
                model = "{{ trigger.payload_json.model }}";
                hw_version = "gen{{ trigger.payload_json.gen }}";
                sw_version = "{{ trigger.payload_json.fw_id }}";
                mac =
                  "{{ trigger.payload_json.mac | regex_replace(find='(..)(..)(..)(..)(..)(..)', replace='\\\\1:\\\\2:\\\\3:\\\\4:\\\\5:\\\\6') }}";
              };
            }
            { delay.seconds = 1; }
            {
              action = "script.shelly_broadcast_command";
              data.command = "status_update";
            }
          ];
        }
      ];
    };
  };
}
