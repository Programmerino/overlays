final: prev:

with import ../modules/compilers.nix final prev;

{
  ${builtins.baseNameOf ./.} = gnat9;
}
