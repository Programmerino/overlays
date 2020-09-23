[
  ( #self: super:
    final: prev:

    with import ./modules/compilers.nix final prev;

    {
      android-udev-rules = (prev.callPackage (prev.path + "/pkgs/os-specific/linux/android-udev-rules") { }).overrideAttrs (oldAttrs: {
        installPhase = oldAttrs.installPhase + ''
      sed -i \
        -e 's/ATTR{idVendor}=="2b4c", ENV{adb_user}="yes"/&\n\n# Vivo\nATTR{idVendor}=="2d95", ENV{adb_user}="yes"/' \
        $out/lib/udev/rules.d/51-android.rules
    '';
      });


      conky-nox = prev.callPackage (prev.path + "/pkgs/os-specific/linux/conky") {
        x11Support = false;
      };

      dmenu = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dmenu/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dmenu/patches/${x}") patchFiles;
      in
        prev.callPackage (prev.path + "/pkgs/applications/misc/dmenu") {
          patches = [
            (prev.path + "/pkgs/applications/misc/dmenu/xim.patch")
          ] ++ patches;
        };

      dwm = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dwm/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dwm/patches/${x}") patchFiles;
      in (prev.callPackage (prev.path + "/pkgs/applications/window-managers/dwm") {
        inherit patches;
      }).overrideAttrs (oldAttrs: {
        postPatch = ''
      substituteInPlace dwm.c \
        --replace '@psmisc@' '${final.pkgs.psmisc}/bin/'
      substituteInPlace config.def.h \
        --replace '@dmenu@' '${final.pkgs.dmenu}/bin/' \
        --replace '@j4_dmenu_desktop@' '${final.pkgs.j4-dmenu-desktop}/bin/' \
        --replace '@alacritty@' '${final.pkgs.alacritty}/bin/'
    '';
      });

      inherit gnat gnat6 gnat9 gnatboot;

      nixpkgs-manual = prev.callPackage (prev.path + "/doc") { };

      ungoogled-chromium = prev.callPackage ./ungoogled-chromium/package (prev.config.chromium or {});

      zathura = prev.callPackage (prev.path + "/pkgs/applications/misc/zathura") {
        useMupdf = true;
      };

    })
]
