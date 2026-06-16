{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "immich-upload-optimizer";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "miguelangel-nubla";
    repo = "immich-upload-optimizer";
    rev = "v${version}";
    hash = "sha256-hjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
  };

  meta = {
    description = "Automatically optimize files uploaded to Immich in order to save storage space";
    homepage = "https://github.com/miguelangel-nubla/immich-upload-optimizer";
    license = lib.licenses.mit;
  };
}
