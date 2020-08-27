self: super:

with builtins;

{
  ${baseNameOf ./.} = let
    seriesFile = split "\n" (readFile ./patches/series);
    patchFiles = filter (x: ! isList x && x != "") seriesFile;
    patches = map (x: ./. + "/patches/${x}") patchFiles;
  in
    super.callPackage <nixpkgs/pkgs/applications/misc/dmenu> {
      patches = [
        <nixpkgs/pkgs/applications/misc/dmenu/xim.patch>
      ] ++ patches;
    };
}
