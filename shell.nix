{ sources ? import ./nix/sources.nix }:
with (import sources.nixpkgs {}).pkgs;

mkShell {
  packages = [ nodejs-16_x python3 ];
}
