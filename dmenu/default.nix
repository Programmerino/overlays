self: super:

with builtins;

{
  ${baseNameOf ./.} = let
    seriesFile = split "\n" (readFile ./patches/series);
    patchFiles = filter (x: ! isList x && x != "") seriesFile;
    patches = map (x: ./. + "/patches/${x}") patchFiles;
  in
    super.callPackage (super.path + /. + "/pkgs/applications/misc/dmenu") {
      patches = [
        (super.path + /. + "/pkgs/applications/misc/dmenu/xim.patch")
      ] ++ patches;
    };
}
