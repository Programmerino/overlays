# nix overlays

My nix overlays.

## Usage

Add the following to your `/etc/nixos/configuration.nix`:

```nix
{
  nixpkgs.overlays = [ (import /path/to/this/repo/overlays.nix) ];
}
```
