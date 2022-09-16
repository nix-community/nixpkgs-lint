# Semantic linter for nixpkgs using tree-sitter 🌳 + ❄️

[![asciicast](https://asciinema.org/a/483977.svg)](https://asciinema.org/a/483977)

This is a semantic linter for nixpkgs that uses
[tree-sitter](https://tree-sitter.github.io/tree-sitter/).  Currently
we have the following detections:

- [x] `cmake`, `makeWrapper`, `pkg-config` in `buildInputs`
- [x] redundant packages from `stdenv` in `nativeBuildInputs`

## Features
- **Fast**: lints all of Nixpkgs in under 10 seconds
- **Semantic linting**: forget about hacking up regexes, we run
  queries directly on parse trees created by tree-sitter
- **Syntax-aware**: `nixpkgs-lint` can easily handle multi-line
  expressions, eliminates false-positives from strings and comments
  and gives exact spans for matches
- **Robust**: lint Nix files even in the presence of syntax errors
- **Hackable**: create your own lints by writing queries or by using
  TypeScript

## Usage
To use without installing, run `nix run github:nix-community/nixpkgs-lint`.

The tool will recurse through every `.nix` file in the
provided path(,s).
```ShellSession
$ nix build 
$ ./result/bin/nixpkgs-lint <files or directories>
```

## Motivation
Why another linter?  My motivation for this was spawned after doing a
series of treewide PRs such as [moving cmake to
buildInputs](https://github.com/NixOS/nixpkgs/pull/108022).  The
strategy was similar each time; write some shell one-liner to go
through every file (27,000+ of them) in Nixpkgs and find some anti-pattern to fix.
However, this is quickly problematic for multiple reasons:

- it is hard to account for multi-line expressions
- it is hard to filter out false positives
- it is hard to query for more complex features

In general discussions on IRC and Matrix, a more AST-aware approach to
linting was viewed favorably but not many people took it on, despite
the availability of Nix parsers in various languages.  I have some
subjective reasons myself:

- need to learn the AST representation in the respective library
- need to traverse the AST with a query
- need to locate this information back to a source location

Often one or more of these would be pretty involved.  Furthermore, it
locks you into a specific parser (which may or may not have provided
source information, parse all things correctly, etc.).

Enter tree-sitter.  The [Nix grammar for
tree-sitter](https://github.com/cstrahan/tree-sitter-nix) has been
well-tested and tree-sitter having bindings in several languages gives
you options in how to work with the resulting AST.  You also get
things like a location-annotated AST and error recovery for free.

## License
This repository is licensed under the MIT license.
