{ lib
, buildGoModule
, fetchFromGitHub
}:

let
  pname = "immich-upload-optimizer";
  version = "0.5.3";
in buildGoModule {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "miguelangel-nubla";
    repo = pname;
    rev = "962dec12e289174bbf82025d04e6bfb589c11f3c";
    hash = "sha256-fern8v8rAUm/kN/xKUnuw9XgTO6JG5LtuPztVrTlWoY=";
  };
  vendorHash = "sha256-v5/xCCaHoYRqvJS9eBv/H36ZFH3p3aS39ZJPg4OUVyQ=";
  meta = with lib; {
    description = "Automatically optimize files uploaded to Immich in order to save storage space";
    homepage = "https://github.com/miguelangel-nubla/immich-upload-optimizer";
    license = licenses.mit;
  };
}
