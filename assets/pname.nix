{ stdenv, fetchFromGitHub, }:

stdenv.mkDerivation rec {
    pname = "test";
    version = "1.0";

    src = fetchFromGitHub {
        owner = "random";
        repo = pname;
        tag = version;
        hash = "";
    };
}
