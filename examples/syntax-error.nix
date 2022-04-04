{ stdenv, pkg-config }:

stdenv.mkDerivation {
  I am an error
  buildInputs = [
    # We want to use pkg-config
    pkg-config
  ];
}
