self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage (self.path + /. + "/pkgs/applications/misc/zathura") {
    useMupdf = true;
  };
}
