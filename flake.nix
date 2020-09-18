{
  description = "My nix overlays";

  outputs = { self, nixpkgs }:
    let

      systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      forAllSystems = f: lib.genAttrs systems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = self.overlay;
        }
      );

      derivations = [
        "android-udev-rules"
        "conky-nox"
        "dmenu"
        "dwm"
        "gnat"
        "gnat6"
        "gnat9"
        "gnatboot"
        "nixpkgs-manual"
        "ungoogled-chromium"
        "zathura"
      ];

      lib = nixpkgs.lib;

    in {

      packages = forAllSystems (system:
        builtins.listToAttrs (builtins.map (x: { name = x;
                                                 value = nixpkgsFor.${system}.${x}; }) derivations)
      );

      overlay = builtins.map (x: import (./. + "/${x}")) derivations;
  
    };
}
