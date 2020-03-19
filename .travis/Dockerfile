FROM nixos/nix

RUN nix-channel --add https://nixos.org/channels/nixos-20.03                        nixos \
 && nix-channel --add https://nixos.org/channels/nixos-unstable                     nixos-unstable \
 && nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
RUN nix-channel --update

VOLUME /configuration
ENTRYPOINT [ "/configuration/.travis/entrypoint.sh" ]
