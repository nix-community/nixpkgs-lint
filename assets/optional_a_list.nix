{ deployAndroidPackage, lib, os, autoPatchelfHook, pkgs, stdenv }:

deployAndroidPackage {
  bruh = optional bruh bruh2;
  bruh1 = optional bruh [ bruh3 ];
  nativeBuildInputs = [ autoPatchelfHook ] ++ lib.optional true [ pkgs.bruh ];
  buildInputs = lib.optional (os == "linux") [ pkgs.stdenv.cc.libc pkgs.stdenv.cc.cc pkgs.ncurses5 ];
}

