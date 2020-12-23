let
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

  /* Fetch an archive from Github and return the store path.
     Example:
       fetchGithub {
         name = "channel-nixos-nixpkgs-nixos-20.09";
         owner = "nixos";
         repo = "nixpkgs";
         rev = "b94726217f7cdc02ddf277b65553762d520da196";
         sha256 = "1v3v7f2apmsdwv1w6hvsxr8whggjbiaxy00k47pxdzyigxv3s400";
       }
     => "/nix/store/r69hpwrl2anwl8yzc5hd7n8zfwdrx1mr-channel-nixos-nixpkgs-nixos-20.09"
  */
  fetchGithub = { name, owner, repo, rev, sha256 }:
    builtins.fetchTarball {
      inherit name sha256;
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    };

  # Fetch a channel archive from a github "pin file".
  fetchChannel = pinFile:
    let ghInfos = importJSON pinFile;
    in fetchGithub {
      name = "channel-${ghInfos.owner}-${ghInfos.repo}-${ghInfos.ref}";
      inherit (ghInfos) owner repo rev sha256;
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
