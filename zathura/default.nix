self: super:

{
  zathura = super.callPackage <nixpkgs/pkgs/applications/misc/zathura> {
    useMupdf = true;
  };
}
