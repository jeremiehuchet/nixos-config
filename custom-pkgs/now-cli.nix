{ stdenv, lib, fetchurl, pkgs }:
stdenv.mkDerivation rec {
  pname = "now-cli";
  version = "17.0.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/now/-/now-${version}.tgz";
    sha256 = "097pqbfk3w6xbmg3x0b6q7rqcgnhn5zwinh2isddz4wmq0snmgqj";
  };

  buildInputs = [ pkgs.nodejs_latest ];

  sourceRoot = ".";
  unpackCmd = ''
    gunzip $curSrc
  '';

  installPhase = ''
    mkdir -p $out/bin $out/usr/share
    cp -r package/dist $out/usr/share/now-cli
    cat - <<EOF > $out/bin/now
    #!${pkgs.nodejs_latest}/bin/node
    require("$out/usr/share/now-cli/index.js");
    EOF
    chmod 555 $out/bin/now
  '';

  meta = with stdenv.lib; {
    homepage = https://zeit.co/now;
    description = "The Command Line Interface for Now - Global Serverless Deployments";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [];
  };
}