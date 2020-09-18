self: super:

with builtins;

let
  seriesFile = split "\n" (readFile ./patches/series);
  patchFiles = filter (x: ! isList x && x != "") seriesFile;

  patches = map (x: ./. + "/patches/${x}") patchFiles;
in
{
  ${baseNameOf ./.} = (super.callPackage (self.path + /. + "/pkgs/applications/window-managers/dwm") {
    inherit patches;
  }).overrideAttrs (oldAttrs: {
    postPatch = ''
      substituteInPlace dwm.c \
        --replace '@psmisc@' '${self.pkgs.psmisc}/bin/'
      substituteInPlace config.def.h \
        --replace '@dmenu@' '${self.pkgs.dmenu}/bin/' \
        --replace '@j4_dmenu_desktop@' '${self.pkgs.j4-dmenu-desktop}/bin/' \
        --replace '@alacritty@' '${self.pkgs.alacritty}/bin/'
    '';
  });
}
