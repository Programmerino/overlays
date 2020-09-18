self: super:

with builtins;

{
  ${baseNameOf ./.} = (super.callPackage (super.path + /. + "/pkgs/os-specific/linux/android-udev-rules") { }).overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      sed -i \
        -e 's/ATTR{idVendor}=="2b4c", ENV{adb_user}="yes"/&\n\n# Vivo\nATTR{idVendor}=="2d95", ENV{adb_user}="yes"/' \
        $out/lib/udev/rules.d/51-android.rules
    '';
  });
}
