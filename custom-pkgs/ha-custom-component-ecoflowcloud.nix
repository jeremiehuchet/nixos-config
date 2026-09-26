{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, buildHomeAssistantComponent
, setuptools
, jsonpath-ng
, paho-mqtt
, protobuf6
}:

buildHomeAssistantComponent rec {
  owner = "tolwi";
  domain = "ecoflow_cloud";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "tolwi";
    repo = "hassio-ecoflow-cloud";
    rev = "refs/tags/v${version}";
    hash = "sha256-x0K+yxOMnnorz7KFLWHDN3Dt84q1yRfTe1f5uVizs5o=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'protobuf==6.32.0' 'protobuf>=6.32.0'
    substituteInPlace custom_components/ecoflow_cloud/manifest.json \
      --replace-fail 'protobuf==6.32.0' 'protobuf>=6.32.0'
  '';

  propagatedBuildInputs = [
    jsonpath-ng
    paho-mqtt
    protobuf6
  ];

  meta = with lib; {
    changelog = "https://github.com/tolwi/hassio-ecoflow-cloud/releases/tag/v${version}";
    description = "EcoFlow Cloud Integration for Home Assistant";
    homepage = "https://github.com/tolwi/hassio-ecoflow-cloud";
    maintainers = with maintainers; [];
    license = licenses.unlicense;
  };
}
