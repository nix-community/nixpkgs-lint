{ stdenv, pkg-config, bash, zsh, coreutils }:

stdenv.mkDerivation {
  nativeBuildInputs = [
    coreutils
  ];
  buildInputs = [
    pkg-config bash
  ] ++ [ zsh fish ] ++ [ ash ] ++ [ something ];
}
