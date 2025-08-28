{ stdenv, fetchFromGitHub, }:

stdenv.mkDerivation (finalAttrs: {
    pname = "test";
    version = "1.0";

    src = fetchFromGitHub {
        owner = "random";
        repo = finalAttrs.pname;
        tag = finalAttrs.version;
        hash = "";
    };
})
