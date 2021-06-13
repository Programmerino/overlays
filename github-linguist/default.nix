{ nixpkgs ? import <nixpkgs> { } }:

with nixpkgs;

let
  gems = {
    escape_utils = {
      groups = ["default"];
      platforms = [];
      source = {
        remotes = ["https://rubygems.org"];
        sha256 = "0qminivnyzwmqjhrh3b92halwbk0zcl9xn828p5rnap1szl2yag5";
        type = "gem";
      };
      version = "1.2.1";
    };
    github-linguist = {
      dependencies = ["charlock_holmes" "escape_utils" "mini_mime" "rugged"];
      groups = ["default"];
      platforms = [];
      source = {
        remotes = ["https://rubygems.org"];
        sha256 = "0636098bksd24dfy8kgvfjdhmy678ni4k5cfvki9npx2kzmjjsjl";
        type = "gem";
      };
      version = "7.15.0";
    };
  };
in
(import (nixpkgs.path + "/pkgs/development/ruby-modules/with-packages") {
  inherit lib stdenv makeWrapper buildRubyGem buildEnv ruby;
  gemConfig = defaultGemConfig;
}).buildGems ((import (nixpkgs.path + "/pkgs/top-level/ruby-packages.nix")) // gems)
