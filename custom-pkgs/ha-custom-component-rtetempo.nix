{ lib
, fetchFromGitHub
, fetchPypi
, buildHomeAssistantComponent
, requests-oauthlib
}:

buildHomeAssistantComponent rec {
  owner = "hekmon";
  domain = "rtetempo";
  version = "1.3.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "rtetempo";
    rev = "refs/tags/v${version}";
    hash = "sha256-MLZeX6WNUSgVEv8zapAkkBKY5R1l5ykCcWTleYF0H5o=";
  };

  dependencies = [ requests-oauthlib];
  dontCheckManifest = true;

  meta = with lib; {
    changelog = "https://github.com/hekmon/rtetempo/releases/tag/v${version}";
    description = "RTE Tempo days calendar and sensors for Home Assistant";
    homepage = "https://github.com/hekmon/rtetempo";
    maintainers = with maintainers; [];
    license = licenses.mit;
  };
}
