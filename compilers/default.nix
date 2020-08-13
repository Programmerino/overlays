final: prev:

let
  # Taken from <nixpkgs/pkgs/top-level/stage.nix>
  #
  # Non-GNU/Linux OSes are currently "impure" platforms, with their libc
  # outside of the store.  Thus, GCC, GFortran, & co. must always look for files
  # in standard system directories (/usr/include, etc.)
  noSysDirs = final.stdenv.buildPlatform.system != "x86_64-freebsd"
           && final.stdenv.buildPlatform.system != "i686-freebsd"
           && final.stdenv.buildPlatform.system != "x86_64-solaris"
           && final.stdenv.buildPlatform.system != "x86_64-kfreebsd-gnu";

  wrapCCWith =
    { cc
    , # This should be the only bintools runtime dep with this sort of logic. The
      # Others should instead delegate to the next stage's choice with
      # `targetPackages.stdenv.cc.bintools`. This one is different just to
      # provide the default choice, avoiding infinite recursion.
      bintools ? if final.stdenv.targetPlatform.isDarwin then final.darwin.binutils else final.binutils
    , libc ? bintools.libc
    , extraPackages ? final.stdenv.lib.optional (cc.isGNU or false && final.stdenv.targetPlatform.isMinGW) final.threadsCross
    , ...
    } @ extraArgs:
      prev.callPackage ./cc-wrapper (let self = {
    nativeTools = final.stdenv.targetPlatform == final.stdenv.hostPlatform && final.stdenv.cc.nativeTools or false;
    nativeLibc = final.stdenv.targetPlatform == final.stdenv.hostPlatform && final.stdenv.cc.nativeLibc or false;
    nativePrefix = final.stdenv.cc.nativePrefix or "";
    noLibc = !self.nativeLibc && (self.libc == null);

    isGNU = cc.isGNU or false;
    isClang = cc.isClang or false;

    inherit cc bintools libc extraPackages;
  } // extraArgs; in self);

  wrapCC = cc: wrapCCWith {
    inherit cc;
  };

  gcc6 = prev.lowPrio (wrapCC (prev.callPackage ./gcc/6 {
    inherit noSysDirs;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = with final.stdenv; (!isDarwin && (isi686 || isx86_64));

    libcCross = if final.stdenv.targetPlatform != final.stdenv.buildPlatform then final.libcCross else null;
    threadsCross = if final.stdenv.targetPlatform != final.stdenv.buildPlatform then final.threadsCross else null;

    isl = if !final.stdenv.isDarwin then final.isl_0_14 else null;
  }));

  gcc9 = prev.lowPrio (wrapCC (prev.callPackage ./gcc/9 {
      inherit noSysDirs;

      # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
      profiledCompiler = with final.stdenv; (!isDarwin && (isi686 || isx86_64));

      enableLTO = !final.stdenv.isi686;

      libcCross = if final.stdenv.targetPlatform != final.stdenv.buildPlatform then final.libcCross else null;
      threadsCross = if final.stdenv.targetPlatform != final.stdenv.buildPlatform then final.threadsCross else null;

      isl = if !final.stdenv.isDarwin then final.isl_0_17 else null;
  }));
in
rec {
  gnat = gnat9;

  gnat6 = wrapCC (gcc6.cc.override {
    name = "gnat";
    langC = true;
    langCC = false;
    langAda = true;
    profiledCompiler = false;
    inherit gnatboot;
  });

  gnat9 = wrapCC (gcc9.cc.override {
    name = "gnat";
    langC = true;
    langCC = false;
    langAda = true;
    profiledCompiler = false;
    gnatboot = gnat6;
  });

  gnatboot = wrapCC (prev.callPackage ./gnatboot { });
}
