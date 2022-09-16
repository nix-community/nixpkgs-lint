{ stdenv, pkg-config, cmake }:

stdenv.mkDerivation {
  buildInputs = [
    pkg-config
    cmake
  ];
}
