# NixOS configuration for my hosts

Flake based configuration for hosts `tv` and `laptop`.

## Usage

Rebuild a host (secrets are read from `/etc/nixos/secrets.nix`, hence `--impure`):

```bash
sudo nixos-rebuild switch --flake /etc/nixos#tv --impure
```

Update pinned inputs (replaces the old `pinned-channels` mechanism):

```bash
nix flake update            # update everything
nix flake update nur-packages  # update a single input
```

Inputs are pinned in `flake.lock` (versioned in git).
