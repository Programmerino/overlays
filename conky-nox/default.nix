self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (super.path + /. + "/pkgs/os-specific/linux/conky") {
    x11Support = false;
  };
}
