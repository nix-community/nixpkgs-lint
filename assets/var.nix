{ stdenv }:

stdenv.mkDerivation {
  someFlags = "--flags-should-be-lists-of-strings";
  someCorrectFlags =
    [ "--flags-lists-of-strings" ];
  dontMatchThis = "this";
  dontMatchThisOrThis = [ "this" ];
}
