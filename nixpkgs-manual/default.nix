self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage <nixpkgs/doc> { };
}
