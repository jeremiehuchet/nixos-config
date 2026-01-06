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
            "cover.dining_room_shelly"
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
            "cover.dining_room_shelly"
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
          action = [
            {
              service = "cover.open_cover";
              entity_id = [
                "cover.ground_floor"
                "cover.first_floor"
              ];
            }
          ];
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
          action = [
            {
              service = "cover.close_cover";
              entity_id = [
                "cover.all"
              ];
            }
          ];
        }
      ];
    };
  };
}

