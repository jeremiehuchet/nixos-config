{ lib, pkgs, config, ... }:

let
  device_id = "OpenBK7231T-042BE1";
  device_mac = "A8:80:55:04:2B:E1";
  t = "openbk/${device_id}";

  expire_after = "360";

  declare_entity = args@{ name, ... }:
  let suffix_id = lib.toLower (builtins.replaceStrings [" "] ["_"] name);
  in {
    unique_id = "${device_id}_${suffix_id}";
    object_id = "garage_door_${suffix_id}";
    device = {
      name = "Garage door controller";
      identifiers = [ device_id ];
      connections = [
        ["mac" device_mac]
      ];
    };
    availability_topic = "${t}/connected";
  } // args;

in {

  config = {
    services.home-assistant.config = {
      mqtt = {
        binary_sensor = [
          (declare_entity {
            name = "State";
            device_class = "garage_door";
            state_topic = "${t}/2/get";
            payload_on = "0";  # door opened
            payload_off = "1"; # door closed
            inherit expire_after;
          })
          (declare_entity {
            name = "Position tracker";
            device_class = "problem";
            state_topic = "${t}/7/get";
            value_template = ''
              {%- if value == '0' -%}
              OFF
              {%- elif value == '1' -%}
              ON
              {%- else -%}
              None
              {%- endif -%}
            '';
            inherit expire_after;
          })
        ];
        button = [
          (declare_entity {
            name = "Button";
            command_topic = "${t}/1/set";
            payload_press = 1;
            retain = false;
          })
          (declare_entity {
            name = "Close";
            command_topic = "${t}/6/set";
            payload_press = 1;
            retain = false;
          })
        ];
        cover = [
          (declare_entity {
            name = "Cover";
            device_class = "gate";
            command_topic = "${t}/6/set";
            payload_stop = 0;
            payload_close = 1;
            payload_open = 2;
            state_topic = "${t}/optimistic-state/get";
            position_topic = "${t}/4/get";
            set_position_topic = "${t}/4/set";
            retain = false;
          })
        ];
        sensor = [
          (declare_entity {
            name = "Optimistic state";
            device_class = "enum";
            state_topic = "${t}/optimistic-state/get";
            inherit expire_after;
          })
          (declare_entity {
            name = "Optimistic next button action";
            device_class = "enum";
            state_topic = "${t}/optimistic-next-button-action/get";
            inherit expire_after;
          })
        ];
      };
      "automation manual" = [
        {
          alias = "Request garage door controller status update on HA statup";
          trigger = [
            {
              event = "start";
              platform = "homeassistant";
            }
          ];
          action = [
            {
              service = "mqtt.publish";
              data = {
                topic = "${t}/6/set";
                payload = 9;
              };
            }
          ];
        }
      ];
    };
  };
}
