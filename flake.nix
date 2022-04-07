{
  description = "nix-lint";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, flake-compat }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        nodejs = pkgs.nodejs-16_x;
        yarn = pkgs.yarn.override { inherit nodejs; };
        y2n = pkgs.yarn2nix-moretea.override {
          inherit nodejs yarn;
        };
      in
      {
        packages = {
          default = self.packages.${system}.nix-lint;
          nix-lint = y2n.mkYarnPackage {
            name = "nix-lint";
            src = ./.;
            packageJSON = ./package.json;
            yarnLock = ./yarn.lock;
            yarnNix = ./yarn.nix;
            yarnFlags = [ "--offline" "--frozen-lockfile" "--ignore-engines" ];
            pkgConfig = {
              tree-sitter-nix = {
                #nativeBuildInputs = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [ xcbuild darwin.apple_sdk.frameworks.ApplicationServices ]);
                buildInputs = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [ xcbuild darwin.apple_sdk.frameworks.ApplicationServices ]);
              };
              tree-sitter = {
                #nativeBuildInputs = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [ xcbuild darwin.apple_sdk.frameworks.ApplicationServices ]);
                buildInputs = lib.optionals pkgs.stdenv.isDarwin (with pkgs; [ xcbuild darwin.apple_sdk.frameworks.ApplicationServices ]);
              };
            };

            postConfigure = ''
              cd deps/nix-lint
              yarn tsc
              # Will be patchShebang'ed.
              sed -i '1i#!/usr/bin/env node' built/index.js
              chmod +x built/index.js
              cd ../..
            '';

            yarnPreBuild = ''
              export PYTHON=${pkgs.python3}/bin/python3
              mkdir -p "$HOME/.cache/node-gyp/${nodejs.version}"
              echo 9 > "$HOME/.cache/node-gyp/${nodejs.version}/installVersion"
              ln -sfv "${nodejs}/include" "$HOME/.cache/node-gyp/${nodejs.version}"
            '';
          };
        };

        defaultPackage = self.packages.${system}.default;

        devShells = {
          default = pkgs.mkShell {
            packages = [
              yarn
              nodejs
              y2n.yarn2nix
              pkgs.python3
            ];
          };
        };

        devShell = self.devShells.${system}.default;

      }
    );
}
