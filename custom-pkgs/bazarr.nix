{ lib, python3,  python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "bazarr";
  version = "0.8.4.2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "morpheus65535";
    repo = pname;
    rev = "v${version}"; 
    hash = "sha256:0k39y5pkb8lsp2kjkij58md9px2diniaxa9xg9s2ayiq3zsw4rqk";
  };

  dontBuild = true;
  doCheck = false;

  propagatedBuildInputs = with python3Packages; [ lxml ];

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "Bazarr is a companion application to Sonarr and Radarr.";
    longDescription = "Bazarr manages and downloads subtitles based on your requirements. You define your preferences by TV show or movie and Bazarr takes care of everything for you.";
    license     = licenses.gpl3;
    homepage    = https://bazarr.media;
    maintainers = [];
  };
}
