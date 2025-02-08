{ config, lib, pkgs, ... }:

let
  dataGouvEdfTempoDatasetUrl = "https://www.data.gouv.fr/fr/datasets/r/0c3d1d36-c412-4620-8566-e5cbb4fa2b5a";
  entity_defaults = {
    device = {
      name = "Prix EDF";
      identifiers = [ "edf_prices" ];
    };
    state_topic = "edf/prices";
    command_topic = "edf/prices/cmd";
  };
in {

  config = {

    systemd.timers.edf-prices-retriever = {
      description = "EDF prices retriever";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = 60;
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    systemd.services.edf-prices-retriever = {
      environment = {
        MQTT_USERNAME = "home-assistant";
        MQTT_PASSWORD = "123456";
      };
      serviceConfig = {
        DynamicUser = "yes";
      };
      script = ''
        ${pkgs.duckdb}/bin/duckdb \
            -jsonlines \
            -c "select
                    DATE_DEBUT                as date_debut,
                    PART_FIXE_TTC             as part_fixe,
                    PART_VARIABLE_HCBleu_TTC  as bleu_hc,
                    PART_VARIABLE_HPBleu_TTC  as bleu_hp,
                    PART_VARIABLE_HCBlanc_TTC as blanc_hc,
                    PART_VARIABLE_HPBlanc_TTC as blanc_hp,
                    PART_VARIABLE_HCRouge_TTC as rouge_hc,
                    PART_VARIABLE_HPRouge_TTC as rouge_hp
                from read_csv('${dataGouvEdfTempoDatasetUrl}', decimal_separator=',')
                where P_SOUSCRITE = 9
                order by DATE_DEBUT desc limit 1" \
            | ${pkgs.mosquitto}/bin/mosquitto_pub \
                  -h localhost \
                  -p 1883 \
                  -u "$MQTT_USERNAME" \
                  -P "$MQTT_PASSWORD" \
                  --qos 1 \
                  --retain \
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
        {
          inherit (entity_defaults) device state_topic;
          name = "Date de début des prix";
          unique_id = "edf_prix_tempo_date_debut";
          object_id = "edf_prix_tempo_date_debut";
          device_class = "date";
          state_class = "measurement";
          value_template = "{{ value_json.date_debut }}";
        }
        {
          inherit (entity_defaults) device state_topic;
          name = "Prix abonnement annuel";
          unique_id = "edf_prix_tempo_part_fixe";
          object_id = "edf_prix_tempo_part_fixe";
          device_class = "monetary";
          state_class = "measurement";
          value_template = "{{ value_json.part_fixe | float }}";
          unit_of_measurement = "€";
        }
      ] ++ lib.mapAttrsToList (id: label: {
        inherit (entity_defaults) device state_topic;
        unique_id = "edf_prix_tempo_${id}";
        name = "Prix ${label}";
        object_id = "edf_prix_tempo_${id}";
        state_class = "measurement";
        value_template = "{{ value_json.${id} | float }}";
        unit_of_measurement = "€/kWh";
        icon = "mdi:cash-lock";
      }) {
        bleu_hc = "Bleu HC";
        bleu_hp = "Bleu HP";
        blanc_hc = "Blanc HC";
        blanc_hp = "Blanc HP";
        rouge_hc = "Rouge HC";
        rouge_hp = "Rouge HP";
      } ;

      template = [
        {
          sensor = {
            name = "Coût abonnement EDF aujourd'hui";
            unique_id = "edf_prix_tempo_part_fixe_today";
            device_class = "monetary";
            unit_of_measurement = "€";
            state = ''
              {%- set year = now().year %}
              {%- set month = now().month %}
              {%- set begin = strptime('%s-%s-01' % (year, month), '%Y-%m-%d') %}
              {%- set end = strptime('%s-%s-01' % (year, month + 1), '%Y-%m-%d') %}
              {%- set currentMonthDayCount = (end - begin).days %}
              {%- set monthlyPricing = states('sensor.edf_prix_tempo_part_fixe') | float / 12 %}
              {{- monthlyPricing / currentMonthDayCount -}}
            '';
          };
        }
      ];

    };

  };

}
