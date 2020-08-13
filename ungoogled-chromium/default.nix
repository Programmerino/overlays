self: super:

with builtins;

{
  ${baseNameOf ./.} = super.callPackage ./package (super.config.chromium or {});
}
