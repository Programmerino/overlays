self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage <nixpkgs/pkgs/os-specific/linux/conky> {
    x11Support = false;
  };
}
