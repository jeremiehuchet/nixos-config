{ lib, pkgs, config, ... }:

let
  winky_id = "Winky-7F93B4";
  winky_defaults = {
    device = {
      name = "Winky";
      identifiers = [ winky_id ];
      connections = [ ["mac" "8c:aa:b5:7f:93:b4"] ];
      sw_version = "V55";
      hw_version = "ESP8266";
    };
    expire_after = "3600";
    state_topic = "/xky-8c:aa:b5:7f:93:b4";
  };
in {

  config = {

    services.home-assistant.config.mqtt.sensor = [
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
}
