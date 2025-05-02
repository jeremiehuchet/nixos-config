{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
}:

buildHomeAssistantComponent rec {
  owner = "pulpyyyy";
  domain = "cover_rf_time_based";
  version = "1.1.4";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-custom-components-cover-rf-time-based";
    rev = "${version}";
    hash = "sha256-geMLJcFnTuTV1ocXzThDk4P3WpHzbXvhqBircqd8RXY=";
  };

  #dontCheckManifest = true;

  meta = with lib; {
    changelog = "https://github.com/Pulpyyyy/home-assistant-custom-components-cover-rf-time-based/releases/tag/${version}";
    description = "Time-based cover with customizable scripts or entity to trigger opening, stopping and closing. Position is calculated based on the fraction of time spent by the cover traveling up or down. State can be updated with information based on external sensors.";
    homepage = "https://github.com/Pulpyyyy/home-assistant-custom-components-cover-rf-time-based";
    maintainers = with maintainers; [];
  };
}
