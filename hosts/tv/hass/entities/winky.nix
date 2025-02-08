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
        unique_id = "${winky_id}_energy_total";
        object_id = "winky_energy_total";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BASE | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Bleu HC";
        unique_id = "${winky_id}_energy_bleu_hc";
        object_id = "winky_energy_bleu_hc";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHCJB | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Bleu HP";
        unique_id = "${winky_id}_energy_bleu_hp";
        object_id = "winky_energy_bleu_hp";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHPJB | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Blanc HC";
        unique_id = "${winky_id}_energy_blanc_hc";
        object_id = "winky_energy_blanc_hc";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHCJW | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Blanc HP";
        unique_id = "${winky_id}_energy_blanc_hp";
        object_id = "winky_energy_blanc_hp";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHPJW | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Rouge HC";
        unique_id = "${winky_id}_energy_rouge_hc";
        object_id = "winky_energy_rouge_hc";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHCJR | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Rouge HP";
        unique_id = "${winky_id}_energy_rouge_hp";
        object_id = "winky_energy_rouge_hp";
        device_class = "energy";
        state_class = "total_increasing";
        value_template = "{{ value_json.BBRHPJR | int }}";
        unit_of_measurement = "Wh";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Couleur demain";
        unique_id = "${winky_id}_couleur_demain";
        object_id = "winky_couleur_demain";
        device_class = "enum";
        value_template = ''
          {%- set color = value_json.DEMAIN -%}
          {%- if color == "----" -%}
            {{ None }}
          {%- elif color == "BLEU" -%}
            Bleu
          {%- elif color == "BLAN" -%}
            Blanc
          {%- elif color == "ROUG" -%}
            Rouge
          {%- else -%}
            {{ color }}
          {%- endif -%}
        '';
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Mode";
        unique_id = "${winky_id}_mode";
        object_id = "winky_mode";
        value_template = ''{{ value_json.ModeTic }}'';
        device_class = "enum";
        entity_category = "diagnostic";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Option Tarifaire";
        unique_id = "${winky_id}_optarif";
        object_id = "winky_optarif";
        value_template = ''{{ value_json.OPTARIF }}'';
        device_class = "enum";
        entity_category = "diagnostic";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Intensité souscrite";
        unique_id = "${winky_id}_isousc";
        object_id = "winky_isousc";
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
        object_id = "winky_apower";
        value_template = ''{{ value_json.PAPP | int }}'';
        unit_of_measurement = "VA";
        device_class = "apparent_power";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Période tarifaire en cours";
        unique_id = "${winky_id}_ptec";
        object_id = "winky_ptec";
        value_template = ''
          {%- set period = value_json.PTEC -%}
          {%- if period == "HCJB" -%}
            Bleu HC
          {%- elif period == "HPJB" -%}
            Bleu HP
          {%- elif period == "HCJW" -%}
            Blanc HC
          {%- elif period == "HPJW" -%}
            Blanc HP
          {%- elif period == "HCJR" -%}
            Rouge HC
          {%- elif period == "HPJR" -%}
            Rouge HP
          {%- else -%}
            {{ period }}
          {%- endif -%}
        '';
        device_class = "enum";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Intensité instantanée";
        unique_id = "${winky_id}_iinst";
        object_id = "winky_iinst";
        state_class = "measurement";
        value_template = ''{{ value_json.IINST | int }}'';
        unit_of_measurement = "A";
        device_class = "current";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Intensité maximale";
        unique_id = "${winky_id}_imax";
        object_id = "winky_imax";
        state_class = "measurement";
        value_template = ''{{ value_json.IMAX | int }}'';
        unit_of_measurement = "A";
        device_class = "current";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Groupe horaire";
        unique_id = "${winky_id}_hhphc";
        object_id = "winky_hhphc";
        value_template = ''{{ value_json.HHPHC }}'';
        device_class = "enum";
        entity_category = "diagnostic";
     }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Mot d'état";
        unique_id = "${winky_id}_motdetat";
        object_id = "winky_motdetat";
        value_template = ''{{ value_json.MOTDETAT }}'';
        device_class = "enum";
        entity_category = "diagnostic";
      }
      {
        inherit (winky_defaults) device expire_after state_topic;
        name = "Wifi signal";
        unique_id = "${winky_id}_rssi";
        object_id = "winky_rssi";
        state_class = "measurement";
        value_template = ''{{ value_json.RSSI | int }}'';
        device_class = "signal_strength";
        unit_of_measurement = "dBm";
        entity_category = "diagnostic";
      }
    ];
  };
}
