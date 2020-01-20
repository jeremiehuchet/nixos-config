{ lib, fetchFromGitHub }:

let
  repo = "devicons";
  version = "1.8.0";
in fetchFromGitHub {
  name = "devicons-font";

  owner = "vorillaz";
  repo = repo;
  rev = version;
  sha256 = "0pnb6ij4pr1g9jwq04qrcbkwsrjpna0wnvj5j0idqmxbli72yay2";

  postFetch = ''
    tar xf $downloadedFile
    install -m444 -Dt $out/share/fonts/truetype ${repo}-${version}/fonts/devicons.ttf
  '';

  meta = with lib; {
    description = "Font Awesome - OTF font";
    longDescription = ''
      Devicons is a full stack iconic font ready to be shipped with your next project.
      Created, handcrafted and coded by Theodore Vorillas Devicons contains 85
      vectorized sharp glyphs.
    '';
    homepage = "https://github.com/vorillaz/devicons";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };

}
