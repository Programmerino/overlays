final: prev:

with import ../modules/compilers.nix final prev;

{
  ${builtins.baseNameOf ./.} = wrapCC (gcc6.cc.override {
    name = "gnat";
    langC = true;
    langCC = false;
    langAda = true;
    profiledCompiler = false;
    inherit gnatboot;
  });
}
