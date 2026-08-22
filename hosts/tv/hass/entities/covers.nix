{ lib, pkgs, config, ... }:

{
  config = {
    services.home-assistant.config = {
      cover = [
        {
          platform ="group";
          name = "all covers";
          unique_id = "all";
          entities = [
            #"cover.dining_room_shelly"
            "cover.kitchen_shelly"
            "cover.living_room_shelly"
            "cover.ch4_shelly"
            "cover.velux_bureau"
            "cover.velux_ch1"
            "cover.velux_ch2"
          ];
        }
        {
          platform ="group";
          name = "Ground floor covers";
          unique_id = "ground_floor";
          entities = [
            #"cover.dining_room_shelly"
            "cover.kitchen_shelly"
            "cover.living_room_shelly"
          ];
        }
        {
          platform ="group";
          name = "First floor covers";
          unique_id = "first_floor";
          entities = [
            "cover.ch4_shelly"
            "cover.velux_bureau"
            "cover.velux_ch1"
            "cover.velux_ch2"
          ];
        }
      ];
      template = [
        {
          trigger = [
            { trigger = "time"; at = "sensor.prochaine_ouverture_des_volets"; }
            { trigger = "homeassistant"; event = "start"; }
          ];
          sensor = [
            {
              name = "Prochaine ouverture des volets";
              device_class = "timestamp";
              state = ''
                {% set offset = timedelta(minutes=range(-15, 10) | random, seconds=range(-30, 30) | random) %}
                {% set next_opening = today_at("09:00") + offset %}
                {{ next_opening + timedelta(days=1 if next_opening < now() else 0) }}
              '';
            }
          ];
        }
        {
          trigger = [
            { trigger = "time"; at = "sensor.prochaine_fermeture_des_volets"; }
            { trigger = "homeassistant"; event = "start"; }
          ];
          sensor = [
            {
              name = "Prochaine fermeture des volets";
              device_class = "timestamp";
              state = ''
                {% set offset = timedelta(minutes=range(-30, 30) | random, seconds=range(-30, 30) | random) %}
                {% set next_closing = today_at("22:30") + offset %}
                {{ next_closing + timedelta(days=1 if next_closing < now() else 0) }}
              '';
            }
          ];
        }
      ];
    };
  };
}

