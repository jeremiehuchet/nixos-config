{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, aiosysbus
}:

buildHomeAssistantComponent rec {
  owner = "cyr-ius";
  domain = "livebox";
  version = "2.5.6";

  src = fetchFromGitHub {
    owner = "cyr-ius";
    repo = "hass-livebox-component";
    rev = "refs/tags/${version}";
    hash = "sha256-TrGcq5btYaxpePWDw5hUv3tcPADkWDHaXp1AqGXJrHU=";
  };

  propagatedBuildInputs = [
    aiosysbus
  ];

  meta = with lib; {
    changelog = "https://github.com/cyr-ius/hass-livebox-component/releases/tag/${version}";
    description = "Livebox Component for Home assistant";
    homepage = "https://github.com/cyr-ius/hass-livebox-component";
    maintainers = with maintainers; [];
    license = licenses.mit;
  };
}
