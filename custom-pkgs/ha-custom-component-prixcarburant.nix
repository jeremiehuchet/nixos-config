{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
}:

buildHomeAssistantComponent rec {
  owner = "aohzan";
  domain = "prix_carburant";
  version = "3.26.4";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-prixcarburant";
    rev = "refs/tags/${version}";
    hash = "sha256-ya8ZGeU8uPjwtQbm9+uZDDjsLictxPvy/qH0BlLEID8=";
  };

  meta = with lib; {
    changelog = "https://github.com/aohzan/hass-prixcarburant/releases/tag/${version}";
    description = "Récupération des prix des stations en France";
    homepage = "https://github.com/aohzan/hass-prixcarburant";
    maintainers = with maintainers; [];
    license = licenses.asl20;
  };
}
