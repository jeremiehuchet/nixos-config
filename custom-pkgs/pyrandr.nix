{ stdenv, fetchFromGitHub, python3, xrandr }:

stdenv.mkDerivation {
  name = "pyrandr";

  src = fetchFromGitHub {
    owner = "jeremiehuchet";
    repo = "pyrandr";
    rev = "master";
    sha256 = "18pnnmixkkpcngmafz51fh12m80y51s6jz2jkxrr2lyrrflrv47h";
  };

  buildInputs = [ python3 xrandr ];

  installPhase = ''
    mkdir -p $out/bin
    cp pyrandr.py $out/bin/pyrandr
    chmod 755 $out/bin/pyrandr
  '';

  meta = with stdenv.lib; {
    description =
      "xrandr python wrapper for better screen scale and positioning ";
    license = licenses.unlicense;
    homepage = "https://github.com/jeremiehuchet/pyrandr";
    maintainers = with stdenv.lib.maintainers; [ ];
  };
}
