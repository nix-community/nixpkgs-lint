{ stdenv, makeWrapper }:

stdenv.mkDerivation {
  buildInputs = [
    makeWrapper
  ];
}
