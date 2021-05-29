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

      gaupol = prev.callPackage (
        { lib, python3, fetchFromGitHub, gettext
        , wrapGAppsHook, gobject-introspection
        , gtk3, cairo, gspell, isocodes, gst_all_1
        }:

        python3.pkgs.buildPythonApplication {
          pname = "gaupol";
          version = "1.9";

          src = fetchFromGitHub {
            owner = "otsaloma";
            repo = "gaupol";
            rev = "3d4a37e36581b0ccbc8616ec0473608d0706df11";
            hash = "sha256-s9uM4MTgOT1HVA3nlQZy7fMfBzEhRHRrhcJFyC16stY=";
          };

          nativeBuildInputs = [
            gettext
            wrapGAppsHook # GI_TYPELIB_PATH
            gobject-introspection
          ];

          buildInputs = [
            gobject-introspection
            gtk3
            cairo
            gspell
            isocodes
          ] ++ (with gst_all_1; [
            gstreamer
            gst-plugins-base
            gst-plugins-good
            gst-plugins-bad
            gst-plugins-ugly
            gst-libav
          ]);

          propagatedBuildInputs = [
            python3.pkgs.pygobject3
            python3.pkgs.chardet
            python3.pkgs.pycairo
          ];

          doCheck = false;

          postPatch = ''
            line=$(grep -n '# Allow --root to be used like DESTDIR.' setup.py | sed 's,:.*,,')
            start=$(( $line - 2 ))
            stop=$(( $line + 3 ))
            sed -i -e "''${start},''${stop}d" setup.py
            sed -i -e "''${start}i\        prefix = '$out'" setup.py
          '';

          meta = with lib; {
            description = "Editor for text-based subtitles";
            homepage = "https://otsaloma.io/gaupol/";
            license = licenses.gpl3;
            maintainers = [ { name = "Azure Zanculmarktum";
                              email = "zanculmarktum@gmail.com"; }
                          ];
            platforms = platforms.all;
          };
        }) { };

      haskellPackages = (prev.dontRecurseIntoAttrs prev.haskell.packages.ghc8104).override {
        overrides = self: super: with prev.haskell.lib; {

          xmobar = overrideCabal super.xmobar
            (drv: { doCheck = false;
                    configureFlags = [ "-fwith_utf8" "-fwith_rtsopts" "-fwith_weather"
                                       "-fwith_xft" "-fwith_xpm" ];
                  });

          termonad = overrideSrc super.termonad
            { src = prev.fetchFromGitHub
              { owner = "zanculmarktum";
                repo = "termonad";
                rev = "0f8028d1ce6e978e42bf1f889eca91af3f72746c";
                sha256 = "sha256-/ingpNbG9dRT3lachfJl/Ynb7tynZbefuO0KJ0UeJao=";
              };
              version = "0f8028d";
            };

        };
      };

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

      microsoft-edge-dev = prev.callPackage ./microsoft-edge-dev { };

      nix-index = prev.nix-index.override {
        nix = final.nixFlakes;
      };

      nixpkgs-manual = prev.callPackage (prev.path + "/doc") { };

      #systemd = prev.systemd.overrideAttrs (oldAttrs: {
      #  mesonFlags = oldAttrs.mesonFlags ++ [ "-Ddns-servers=''" ];
      #});

      ungoogled-chromium = prev.ungoogled-chromium.override {
        enableVaapi = true;
      };

      zathura = prev.zathura.override {
        useMupdf = true;
      };
    })
]
