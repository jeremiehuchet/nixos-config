{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
}:

buildHomeAssistantComponent rec {
  owner = "jeremiehuchet";
  domain = "cover_time_based_synced";
  version = "2.2.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-custom-components-cover-time-based-synced";
    rev = version;
    hash = "sha256-x5lsBVNZz2haOaSJ+iDjaQmcLVPO5qSFF9ZwkjnTW5Y=";
  };

  dontCheckManifest = true;

  meta = with lib; {
    changelog = "https://github.com/jeremiehuchet/home-assistant-custom-components-cover-time-based-synced/releases/tag/${version}";
    description = "Cover Time Based Component for your Home-Assistant based on davidramosweb's Cover Time Based Component and nagyrobi's Cover RF Time based, modified to sync state of cover with the state of switches.";
    homepage = "https://github.com/jeremiehuchet/home-assistant-custom-components-cover-time-based-synced";
    maintainers = with maintainers; [];
  };
}
