{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, buildHomeAssistantComponent
, setuptools
, jsonpath-ng
, paho-mqtt
, protobuf5
}:

buildHomeAssistantComponent rec {
  owner = "tolwi";
  domain = "ecoflow_cloud";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "tolwi";
    repo = "hassio-ecoflow-cloud";
    rev = "refs/tags/v${version}";
    hash = "sha256-CVm5+zLWN/ayhHRNFUr4PLwedwf4GJXvLOFgrh2qxAc=";
  };

  propagatedBuildInputs = [
    jsonpath-ng
    paho-mqtt
    protobuf5
  ];

  meta = with lib; {
    changelog = "https://github.com/tolwi/hassio-ecoflow-cloud/releases/tag/v${version}";
    description = "EcoFlow Cloud Integration for Home Assistant";
    homepage = "https://github.com/tolwi/hassio-ecoflow-cloud";
    maintainers = with maintainers; [];
    license = licenses.unlicense;
  };
}
