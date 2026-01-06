{ config, lib, pkgs, ... }:

let
  dataGouvEdfTempoDatasetUrl =
    "https://www.data.gouv.fr/fr/datasets/r/0c3d1d36-c412-4620-8566-e5cbb4fa2b5a";
  entity_defaults = {
    device = {
      name = "Prix EDF";
      identifiers = [ "edf_prices" ];
    };
    state_topic = "energy/edf-prices";
  };
  secrets = import ../../../../secrets.nix;
in {

  config = {

    systemd.timers.edf-prices-retriever = {
      description = "EDF prices retriever";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = 60;
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    systemd.services.edf-prices-retriever = {
      environment = {
        MQTT_USERNAME = "home-assistant";
        MQTT_PASSWORD = secrets.home-automation.mosquitto.hass.password;
      };
      serviceConfig = { DynamicUser = "yes"; };
      script = ''
        ${pkgs.wget}/bin/wget -O - '${dataGouvEdfTempoDatasetUrl}' \
            | ${pkgs.duckdb}/bin/duckdb \
                  -jsonlines \
                  -c "
                    select
                        DATE_DEBUT                as date_debut,
                        DATE_FIN                  as date_fin,
                        PART_FIXE_TTC             as part_fixe,
                        PART_VARIABLE_HCBleu_TTC  as bleu_hc,
                        PART_VARIABLE_HPBleu_TTC  as bleu_hp,
                        PART_VARIABLE_HCBlanc_TTC as blanc_hc,
                        PART_VARIABLE_HPBlanc_TTC as blanc_hp,
                        PART_VARIABLE_HCRouge_TTC as rouge_hc,
                        PART_VARIABLE_HPRouge_TTC as rouge_hp
                    from read_csv('/dev/stdin', decimal_separator = ',')
                    where P_SOUSCRITE = 9
                    order by DATE_DEBUT desc limit 1
                  " \
            | ${pkgs.mosquitto}/bin/mosquitto_pub \
                  -h localhost \
                  -p 1883 \
                  -u "$MQTT_USERNAME" \
                  -P "$MQTT_PASSWORD" \
                  --qos 1 \
                  -r \
                  --stdin-file \
                  -t "${entity_defaults.state_topic}" 
      '';
    };

    services.home-assistant.config = {
      frontend.themes."Custom" = {
        modes = {
          # Bleu Heures Creuses
          # Bleu Heures Pleines
          # Blanc Heures Creuses
          # Blanc Heures Pleines
          # Rouge Heures Creuses
          # Rouge Heures Pleines
          dark = {
            energy-grid-consumption-color-0 = "#5F87C7";
            energy-grid-consumption-color-1 = "#1057C8";
            energy-grid-consumption-color-2 = "#E8E8E8";
            energy-grid-consumption-color-3 = "#BFBFBF";
            energy-grid-consumption-color-4 = "#E89E8E";
            energy-grid-consumption-color-5 = "#E85130";
          };
          light = {
            energy-grid-consumption-color-0 = "#5F87C7";
            energy-grid-consumption-color-1 = "#1057C8";
            energy-grid-consumption-color-2 = "#E8E8E8";
            energy-grid-consumption-color-3 = "#BFBFBF";
            energy-grid-consumption-color-4 = "#E89E8E";
            energy-grid-consumption-color-5 = "#E85130";
          };
        };
      };

      mqtt.sensor = [
        ({
          name = "Date de début des prix";
          unique_id = "edf_prix_tempo_date_debut";
          default_entity_id = "edf_prix_tempo_date_debut";
          device_class = "date";
          value_template = "{{ value_json.date_debut }}";
        } // entity_defaults)
        ({
          name = "Date de fin des prix";
          unique_id = "edf_prix_tempo_date_fin";
          default_entity_id = "edf_prix_tempo_date_fin";
          device_class = "date";
          value_template = "{{ value_json.date_fin }}";
        } // entity_defaults)
        ({
          name = "Prix abonnement annuel";
          unique_id = "edf_prix_tempo_part_fixe";
          default_entity_id = "edf_prix_tempo_part_fixe";
          #device_class = "monetary";
          state_class = "measurement";
          value_template = "{{ value_json.part_fixe | float }}";
          unit_of_measurement = "€";
        } // entity_defaults)
      ] ++ lib.mapAttrsToList (id: label:
        ({
          unique_id = "edf_prix_tempo_${id}";
          name = "Prix ${label}";
          default_entity_id = "edf_prix_tempo_${id}";
          #device_class = "monetary";
          state_class = "measurement";
          value_template = "{{ value_json.${id} | float }}";
          unit_of_measurement = "€/kWh";
          icon = "mdi:cash-lock";
        } // entity_defaults)) {
          bleu_hc = "Bleu HC";
          bleu_hp = "Bleu HP";
          blanc_hc = "Blanc HC";
          blanc_hp = "Blanc HP";
          rouge_hc = "Rouge HC";
          rouge_hp = "Rouge HP";
        };

      mqtt.binary_sensor = [
        ({
          name = "Prix à jour";
          unique_id = "edf_prix_tempo_obsoletes";
          default_entity_id = "edf_prix_tempo_obsoletes";
          device_class = "problem";
          value_template = ''{% if as_datetime(value_json.date_fin).date() < now().date() %}ON{% else %}OFF{% endif %}'';
          } // entity_defaults)
        ];

      template = [{
        triggers = [
          {
            trigger = "state";
            entity_id = "binary_sensor.mqtt_connector";
            to = "on";
          }
          {
            trigger = "time";
            at = "00:00:00";
          }
          {
            trigger = "state";
            entity_id = "sensor.edf_prix_tempo_part_fixe";
          }
        ];
        sensor = {
          name = "Coût abonnement EDF aujourd'hui";
          unique_id = "edf_prix_tempo_part_fixe_today";
          #device_class = "monetary";
          state_class = "measurement";
          unit_of_measurement = "€";
          state = ''
            {%- set year = now().year %}
            {%- set month = now().month %}
            {%- set begin = strptime('%s-%s-01' % (year, month), '%Y-%m-%d') %}
            {%- set end = strptime('%s-%s-01' % (year, month + 1), '%Y-%m-%d') %}
            {%- set currentMonthDayCount = (end - begin).days %}
            {%- set monthlyPricing = states('sensor.edf_prix_tempo_part_fixe') | float / 12 | round(2) %}
            {{- monthlyPricing / currentMonthDayCount -}}
          '';
        };
      }];

    };

    alert = [{
      edf_prix_tempo_obsoletes = {
        name = "Tarifs EDF obsolètes";
        done_message = "Tarifs EDF à jour";
        entity_id = "binary_sensor.edf_prix_tempo_obsoletes";
        repeat = 60; # once an hour
        can_acknowledge = false;
        skip_first = true;
        notifiers = ["mobile_app_oneplus_9_pro"];
      }
    }];
  };

}
