let
  fetchFromGitHub = (import <nixpkgs> {}).fetchFromGitHub;

  /* Reads a JSON file.
     Type :: path -> any
  */
  importJSON = path: builtins.fromJSON (builtins.readFile path);

  /* Call a function for each attribute in the given set and return
     the result in a list.
     Example:
       mapAttrsToList (name: value: name + value)
          { x = "a"; y = "b"; }
       => [ "xa" "yb" ]
  */
  mapAttrsToList = f: attrs:
    map (name: f name attrs.${name}) (builtins.attrNames attrs);

  # Fetch a channel archive from a github "pin file".
  fetchChannel = pinFile:
    let ghInfos = importJSON pinFile;
    in fetchFromGitHub {
      inherit (ghInfos) owner repo rev hash;
    };

  # Convert a name/value pair to a nixpath entry string.
  toNixPathItem = name: value: "${name}=${value}";

  channels = {
    nixpkgs = fetchChannel ./nixpkgs.json;
    nixpkgs-unstable = fetchChannel ./nixpkgs-unstable.json;
    nixos-hardware = fetchChannel ./nixos-hardware.json;
    home-manager = fetchChannel ./home-manager.json;
    nur-packages = fetchChannel ./nur-packages.json;
  };

  nixPath = mapAttrsToList toNixPathItem channels
    ++ [ "nixos-config=/etc/nixos/configuration.nix" ];

in {
  inherit (channels)
    nixpkgs nixpkgs-unstable nixos-hardware home-manager nur-packages;
  inherit nixPath;
  nixPathString = builtins.concatStringsSep ":" nixPath;
}
