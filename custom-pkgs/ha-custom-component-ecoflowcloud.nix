{ lib
, fetchPypi
, buildPythonPackage
, fetchFromGitHub
, buildHomeAssistantComponent
, setuptools
}:

let
  jsonpath-ng = let
    pname = "jsonpath-ng";
    version = "1.6.1";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-CGw3ukkXMEhQvYN66rgGZwIk0/A4/igz/1k6Zy7wpfo=";
    };
    propagatedBuildInputs = [ ply ];
    pyproject = true;
    build-system = [ setuptools ];
  };
  paho-mqtt = let
    pname = "paho-mqtt";
    version = "1.6.1";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-KoKRyBYjrsADcrWoVVijcsdHy8qOmTTf4hhji47vwm8";
    };
    pyproject = true;
    build-system = [ setuptools ];
  };
  ply = let
    pname = "ply";
    version = "3.11";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-AMfBqqiDWLnHZbbTAAxu7AukKrylNRsJUyGu9EYIHaM=";
    };
    pyproject = true;
    build-system = [ setuptools ];
  };
  protobuf = let
    pname = "protobuf";
    version = "5.28.2";
  in buildPythonPackage {
    inherit pname version;
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-WTeWdP8RlxdAT3RUZHkTeHA08D/nBJy+8ddKl7tFk/A=";
    };
    pyproject = true;
    build-system = [ setuptools ];
  };
in buildHomeAssistantComponent rec {
  owner = "tolwi";
  domain = "ecoflow_cloud";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "tolwi";
    repo = "hassio-ecoflow-cloud";
    rev = "refs/tags/v${version}";
    hash = "sha256-mW2UAjsV5RHi/n5O7b5lowZvCnCm8WIPpUo5Mu7UOr0=";
  };

  propagatedBuildInputs = [
    jsonpath-ng
    paho-mqtt
    protobuf
  ];

  meta = with lib; {
    changelog = "https://github.com/tolwi/hassio-ecoflow-cloud/releases/tag/v${version}";
    description = "EcoFlow Cloud Integration for Home Assistant";
    homepage = "https://github.com/tolwi/hassio-ecoflow-cloud";
    maintainers = with maintainers; [];
    license = licenses.unlicense;
  };
}
