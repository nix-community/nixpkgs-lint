{ sources ? import ./nix/sources.nix }:
with (import sources.nixpkgs { }).pkgs;

let
  ourNode = nodejs-16_x;
  ourYarn = yarn.override { nodejs = ourNode; };
in mkShell {
  packages = [
    ourYarn
    ourNode
    python3
    (yarn2nix-moretea.override {
      nodejs = ourNode;
      yarn = ourYarn;
    }).yarn2nix
  ];
}
