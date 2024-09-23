{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
}:

buildHomeAssistantComponent rec {
  owner = "aohzan";
  domain = "prix_carburant";
  version = "3.7.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-prixcarburant";
    rev = "refs/tags/${version}";
    hash = "sha256-peIRWatsDIbP+7FkzZBjAdYCKdhTKVnHwCTI0Jbtfq4=";
  };

  meta = with lib; {
    changelog = "https://github.com/aohzan/hass-prixcarburant/releases/tag/${version}";
    description = "Récupération des prix des stations en France";
    homepage = "https://github.com/aohzan/hass-prixcarburant";
    maintainers = with maintainers; [];
    license = licenses.asl20;
  };
}
