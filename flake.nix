{
  description = "Semantic linter for nixpkgs using tree-sitter";

  inputs = {
    naersk = {
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, naersk, ... }:
    let
      inherit (nixpkgs) lib;
      nixpkgsLintLambda = pkgs':
        let
          pkgs = pkgs'.__splicedPackages;
          naersk-lib = pkgs.callPackage naersk { };
        in
        naersk-lib.buildPackage {
          pname = "nixpkgs-lint";
          root = ./.;
        };
    in
    utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = {
            default = self.packages."${system}".nixpkgs-lint;
            nixpkgs-lint = nixpkgsLintLambda pkgs;
          };

          apps.default = utils.lib.mkApp {
            drv = self.packages."${system}".default;
          };

          devShells.default = with pkgs; mkShell {
            nativeBuildInputs = [ cargo nix-index rustc rustfmt rustPackages.clippy fzy ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
        })
    // {
      overlays.default = _: prev: {
        nixpkgs-lint = nixpkgsLintLambda prev;
      };
    };
}
