self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (self.path + /. + "/doc") { };
}
