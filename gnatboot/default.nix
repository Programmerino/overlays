final: prev:

with import ../modules/compilers.nix final prev;

{
  ${builtins.baseNameOf ./.} = wrapCC (prev.callPackage ../nixpkgs/pkgs/development/compilers/gnatboot { });
}
