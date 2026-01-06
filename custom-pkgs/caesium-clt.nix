{ lib
, fetchFromGitHub
, rustPlatform
}:

let
  pname = "caesium-clt";
  version = "1.2.0";
in rustPlatform.buildRustPackage {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "Lymphatus";
    repo = pname;
    rev = "4616b17b81fa52376415a555cb8e522b9d822988";
    hash = "sha256-Cgr9SzL+RcN/Y+MiEefx5hpsVizhVeDTNDP2XrsUYp4=";
  };
  cargoHash = "sha256-qmYKpMUw06W9xHPueIz3zNAupm0Z1hL428Qje1LNYVw=";
  meta = with lib; {
    description = "Caesium Command Line Tools - Lossy/lossless image compression tool";
    homepage = "https://github.com/Lymphatus/caesium-clt";
    license = licenses.asl20;
  };
}
