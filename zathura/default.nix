self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (super.path + /. + "/pkgs/applications/misc/zathura") {
    useMupdf = true;
  };
}
