[
  ( #self: super:
    final: prev:

    {
      android-udev-rules = prev.android-udev-rules.overrideAttrs (oldAttrs: {
        installPhase = (oldAttrs.installPhase or "") + ''
          sed -i \
            -e 's/ATTR{idVendor}=="2b4c", ENV{adb_user}="yes"/&\n\n# Vivo\nATTR{idVendor}=="2d95", ENV{adb_user}="yes"/' \
            $out/lib/udev/rules.d/51-android.rules
        '';
      });

      conky-nox = prev.conky.override {
        x11Support = false;
      };

      dmenu = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dmenu/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dmenu/patches/${x}") patchFiles;
      in
        prev.dmenu.override {
          patches = [
            (prev.path + "/pkgs/applications/misc/dmenu/xim.patch")
          ] ++ patches;
        };

      dwm = let
        seriesFile = builtins.split "\n" (builtins.readFile ./dwm/patches/series);
        patchFiles = builtins.filter (x: ! builtins.isList x && x != "") seriesFile;
        patches = builtins.map (x: ./. + "/dwm/patches/${x}") patchFiles;
      in (prev.dwm.override {
        inherit patches;
      }).overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace dwm.c \
            --replace '@psmisc@' '${final.psmisc}/bin/'
          substituteInPlace config.def.h \
            --replace '@dmenu@' '${final.dmenu}/bin/' \
            --replace '@j4_dmenu_desktop@' '${final.j4-dmenu-desktop}/bin/' \
            --replace '@alacritty@' '${final.alacritty}/bin/'
        '';
      });

      # Fix X11 apps not respecting the cursors.
      # https://github.com/NixOS/nixpkgs/issues/24137
      #xorg =
      #  /*
      #  prev.xorg.overrideScope' (self: super: {
      #    libX11 = super.libX11.overrideAttrs (oldAttrs: {
      #      postPatch = (oldAttrs.postPatch or "") + ''
      #        substituteInPlace src/CrGlCur.c --replace "libXcursor.so.1" "${self.libXcursor}/lib/libXcursor.so.1"
      #      '';
      #    });
      #  });
      #  */
      #  prev.xorg // {
      #    libX11 = prev.xorg.libX11.overrideAttrs (oldAttrs: {
      #      postPatch = (oldAttrs.postPatch or "") + ''
      #        substituteInPlace src/CrGlCur.c --replace "libXcursor.so.1" "${final.xorg.libXcursor}/lib/libXcursor.so.1"
      #      '';
      #    });
      #  };

      nixpkgs-manual = prev.callPackage (prev.path + "/doc") { };

      #systemd = prev.systemd.overrideAttrs (oldAttrs: {
      #  mesonFlags = oldAttrs.mesonFlags ++ [ "-Ddns-servers=''" ];
      #});

      zathura = prev.zathura.override {
        useMupdf = true;
      };
    })
]
