{ lib
, fetchPypi
, buildPythonPackage
, aiohttp
, aiomqtt
, paho-mqtt
, requests
, setuptools-scm
}:

let
  pname = "navimow_sdk";
  version = "0.1.2";
in buildPythonPackage {
  inherit pname version;
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fqYnNT9TpcfwvVwq9WBRYKy7yS+rECMW02bye86S++k=";
  };
  pyproject = true;
  build-system = [ setuptools-scm ];
  doCheck = false;
  buildInputs = [];
  checkInputs = [];
  nativeBuildInputs = [];
  propagatedBuildInputs = [
    aiohttp
    requests
    paho-mqtt
    aiomqtt
  ];
}
