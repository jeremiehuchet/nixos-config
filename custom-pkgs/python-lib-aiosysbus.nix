{ lib
, fetchPypi
, buildPythonPackage
, aiohttp
, yarl
}:

let
  pname = "aiosysbus";
  version = "1.1.3";
in buildPythonPackage {
  inherit pname version;
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FNeHM/yTBkOJI4FKeGXfvp12Kq4igtAcqyoU1PS4968=";
  };
  doCheck = false;
  buildInputs = [];
  checkInputs = [];
  nativeBuildInputs = [];
  propagatedBuildInputs = [
    aiohttp
    yarl
  ];
  preBuild = ''
    cat > setup.py << EOF
from setuptools import setup

with open('requirements.txt') as f:
    install_requires = f.read().splitlines()

setup(
  name='${pname}',
  version='${version}',
  install_requires=install_requires,
  scripts=[],
)
EOF
  '';
}
