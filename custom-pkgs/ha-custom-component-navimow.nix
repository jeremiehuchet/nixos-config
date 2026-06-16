{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, navimow-sdk
}:

buildHomeAssistantComponent rec {
  owner = "segwaynavimow";
  domain = "navimow";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "segwaynavimow";
    repo = "NavimowHA";
    rev = "refs/tags/NavimowHA-v${version}";
    hash = "sha256-iBS3bLM8kyigSjmHNRgq0RyHIEpGvmb3T9GvODZe33I=";
  };

  propagatedBuildInputs = [
    navimow-sdk
  ];

  meta = with lib; {
    changelog = "https://github.com/segwaynavimow/NavimowHA/releases/tag/${version}";
    description = "Segway Navimow Official Integration for Home Assistant";
    homepage = "https://github.com/segwaynavimow/NavimowHA";
    maintainers = with maintainers; [];
    license = licenses.unlicense;
  };
}
