self: super:

{
  ungoogled-chromium = super.callPackage ./package (super.config.chromium or {});
}
