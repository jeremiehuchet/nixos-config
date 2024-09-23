{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, buildHomeAssistantComponent
}:

let
  paho-mqtt = let
    pname = "paho-mqtt";
    version = "1.6.1";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-KoKRyBYjrsADcrWoVVijcsdHy8qOmTTf4hhji47vwm8";
    };
  };
  reactivex = let
    pname = "reactivex";
    version = "4.0.4";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-6RLmWRAiq5F234NIplP+jI+nowHyb5kxydjHimUOBOg=";
    };
  };
  protobuf = let
    pname = "protobuf";
    version = "5.27.3";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-gkYJA+ZA8rfjTugalH/arYneeW0yS8vDj/VDC83q2Cw=";
    };
  };
in buildHomeAssistantComponent rec {
  owner = "tolwi";
  domain = "ecoflow_cloud";
  version = "0.13.4";

  src = fetchFromGitHub {
    owner = "tolwi";
    repo = "hassio-ecoflow-cloud";
    rev = "refs/tags/v${version}";
    hash = "sha256-3vMqGA0JTN5S15QmC7ITvxV4e9b36derT6yNcgiBnOQ";
  };

  propagatedBuildInputs = [
    paho-mqtt
    protobuf
    reactivex
  ];

  meta = with lib; {
    changelog = "https://github.com/tolwi/hassio-ecoflow-cloud/releases/tag/v${version}";
    description = "EcoFlow Cloud Integration for Home Assistant";
    homepage = "https://github.com/tolwi/hassio-ecoflow-cloud";
    maintainers = with maintainers; [];
    license = licenses.unlicense;
  };
}
