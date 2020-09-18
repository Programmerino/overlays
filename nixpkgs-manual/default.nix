self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (super.path + /. + "/doc") { };
}
