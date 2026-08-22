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
            entity_id =
              "{{ name | lower | regex_replace(find='[^a-zA-Z0-9-_]+', replace='-') }}";
            device_id = "${entity_id}-{{ id }}";
            common_attributes = {
              origin.name = "Home Assistant configuration";
              "~" =
                "shelly/{{ name | regex_replace(find='[^a-zA-Z0-9-_]+', replace='-') }}";
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
                topic = "~/online";
                payload_available = "true";
                payload_not_available = "false";
              }];
              qos = 2;
            };
          in builtins.map (entity: {
            action = "mqtt.publish";
            data = {
              topic =
                "homeassistant/${entity.platform}/${entity.config.default_entity_id}/config";
              retain = true;
              qos = 1;
              evaluate_payload = true;
              payload = builtins.toJSON (common_attributes // entity.config);
            };
          }) ([
            {
              platform = "cover";
              config = {
                default_entity_id = entity_id;
                device_class = "shutter";
                payload_close = "close";
                payload_open = "open";
                payload_stop = "stop";
                command_topic = "~/command/cover:0";
                position_closed = 0;
                position_open = 100;
                position_template =
                  rawTemplate "{{ value_json.current_pos | int }}";
                position_topic = "~/status/position";
                state_closed = "closed";
                state_closing = "closing";
                state_open = "open";
                state_opening = "opening";
                state_stopped = "stopped";
                state_topic = "~/status/cover:0";
                unique_id = "{{ id }}";
                value_template = rawTemplate "{{ value_json.state }}";
              };
            }
            {
              platform = "binary_sensor";
              config = {
                default_entity_id = "${entity_id}-cloud";
                device_class = "connectivity";
                name = "Shelly cloud";
                entity_category = "diagnostic";
                state_topic = "~/status/cloud";
                value_template = rawTemplate "{{ value_json.connected }}";
                payload_off = "false";
                payload_on = "true";
              };
            }
            {
              platform = "sensor";
              config = {
                default_entity_id = "${entity_id}-rssi";
                device_class = "signal_strength";
                name = "RSSI";
                entity_category = "diagnostic";
                state_class = "measurement";
                state_topic = "~/status/wifi";
                value_template = rawTemplate "{{ value_json.connected }}";
              };
            }
            {
              platform = "sensor";
              config = {
                default_entity_id = "${entity_id}-uptime";
                device_class = "duration";
                name = "Uptime";
                icon = "mdi:timer-outline";
                entity_category = "diagnostic";
                state_class = "total_increasing";
                state_topic = "~/status/sys";
                value_template = rawTemplate "{{ value_json.uptime }}";
                unit_of_measurement = "s";
              };
            }
          ] ++ builtins.map (item: {
            platform = "sensor";
            config = {
              default_entity_id = "${entity_id}-${item}";
              device_class = "data_size";
              name = builtins.replaceStrings [ "_" ] [ " " ] item;
              entity_category = "diagnostic";
              state_class = "measurement";
              state_topic = "~/status/sys";
              value_template = rawTemplate "{{ value_json.${item} }}";
            };
          }) [ "fs_free" "fs_size" "ram_free" "ram_min_free" "ram_size" ]);
        };
      };
      "automation nixos" = [
        {
          alias = "Shelly broadcast 'announce' on start and once a day";
          triggers = [
            {
              trigger = "homeassistant";
              event = "start";
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
              trigger = "homeassistant";
              event = "start";
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
          alias = "Publish shelly config on device announcement";
          mode = "parallel";
          triggers = lib.mapAttrsToList (id: config: {
            trigger = "mqtt";
            topic = "shelly/+/announce";
          }) covers;
          action = [{
            action = "script.shelly_publish_cover_config";
            data = {
              id = "{{ trigger.payload_json.id }}";
              name = "{{ trigger.payload_json.name }}";
              model = "{{ trigger.payload_json.model }}";
              hw_version = "gen{{ trigger.payload_json.gen }}";
              sw_version = "{{ trigger.payload_json.fw_id }}";
              mac =
                "{{ trigger.payload_json.mac | regex_replace(find='(..)(..)(..)(..)(..)(..)', replace='\\1:\\2:\\3:\\4:\\5:\\6') }}";
            };
          }];
        }
      ];
    };
  };
}
