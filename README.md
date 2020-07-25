# nix overlays

My nix overlays.

## Usage

```
# nix-channel --add https://gitlab.com/zanc/overlays/-/archive/master/overlays-master.tar.gz nixpkgs-overlays
# nix-channel --update
```

Add the following to your `/etc/nixos/configuration.nix`:

```nix
with builtins;

{
  nixpkgs.overlays = let
      isDir = path: pathExists (path + "/.");
      pathOverlays = let res = tryEval (toString <nixpkgs-overlays>); in if res.success then res.value else "";
      overlays = path:
        # check if the path is a directory or a file
        if isDir path then
          # it's a directory, so the set of overlays from the directory, ordered lexicographically
          let content = readDir path; in
          map (n: import (path + ("/" + n)))
            (builtins.filter (n: builtins.match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix")))
              (attrNames content))
        else
          # it's a file, so the result is the contents of the file itself
          import path;
    in
      if pathOverlays != "" && pathExists pathOverlays then overlays pathOverlays
      else [];
}
```
