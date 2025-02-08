{ lib
, fetchFromGitHub
, stdenvNoCC
}:

let
  pname = "hatempotheme";
  version = "1.1.0";
in stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "hekmon";
    repo = "hatempotheme";
    tag = "v${version}";
    hash = "sha256-DxYAWmiRBgRInkr4oSE3T3g3XtVugwAHEWCQ6aDvu50=";
  };

  installPhase = ''
    install -Dm 664 $src/themes/* -t $out/themes
  '';

  meta = with lib; {
    changelog = "https://github.com/hekmon/hatempotheme/releases/tag/v${version}";
    description = "Home Assistant Tempo Energy Theme";
    homepage = "https://github.com/hekmon/hatempotheme";
    maintainers = with maintainers; [];
    license = licenses.mit;
  };
}
