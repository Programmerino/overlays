# nix overlays

My nix overlays.

## Usage

Add the following to your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, options, ... }:

let
  nixpkgs-overlays = builtins.fetchTarball "https://gitlab.com/api/v4/projects/zanc%2Foverlays/repository/archive.tar.gz?sha=master";
in {
  nix.nixPath = options.nix.nixPath.default ++ [ "nixpkgs-overlays=${nixpkgs-overlays}/overlays.nix" ];
  nixpkgs.overlays = import (nixpkgs-overlays + "/overlays.nix");
}
```

To pin, simply change `sha=master` to `sha=0000000000000000000000000000000000000000`.
