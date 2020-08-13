self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage <nixpkgs/pkgs/applications/misc/zathura> {
    useMupdf = true;
  };
}
