{ stdenv, pkg-config }:

stdenv.mkDerivation {
  buildInputs = [
    # We want to use pkg-config
    pkg-config
  ];
}
