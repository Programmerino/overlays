self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (self.path + /. + "/pkgs/os-specific/linux/conky") {
    x11Support = false;
  };
}
