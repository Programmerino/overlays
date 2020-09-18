final: prev:

with import ../modules/compilers.nix final prev;

{
  ${builtins.baseNameOf ./.} = wrapCC (gcc9.cc.override {
    name = "gnat";
    langC = true;
    langCC = false;
    langAda = true;
    profiledCompiler = false;
    gnatboot = gnat6;
  });
}
