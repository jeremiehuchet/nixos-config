{ fetchFromGitHub, ... }:

let
  version = "a65382a353eaee5a98f068c330947c032a1263bb";
  pname = "zsh-nix-shell";
in fetchFromGitHub {
  owner = "chisui";
  repo = "zsh-nix-shell";
  rev = version;
  sha256 = "0l41ac5b7p8yyjvpfp438kw7zl9dblrpd7icjg1v3ig3xy87zv0n";
}
