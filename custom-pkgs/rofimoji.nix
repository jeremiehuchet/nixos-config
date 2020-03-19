{ stdenv, lib, fetchurl, rofi, xdotool, xsel, python3, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "rofimoji";
  version = "3.0.0";

  src = fetchurl {
    url = "https://git.teknik.io/matf/${pname}/archive/${version}.tar.gz";
    hash = "sha256:0sbbl4nkrbjqi97r09fbgd3yl3hf0613v23qjncbbcgj9nizdl5w";
  };

  dontBuild = true;

  buildInputs = [ python3 rofi ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -vD rofimoji.py $out/bin/rofimoji
    wrapProgram $out/bin/rofimoji \
      --prefix PATH : ${lib.makeBinPath [ xdotool xsel ]}
  '';

  meta = with stdenv.lib; {
    homepage = "https://git.teknik.io/matf/rofimoji";
    description = "A simple emoji picker for rofi with multi-selection";
    license = licenses.mit;
    maintainers = [ ];
  };
}
