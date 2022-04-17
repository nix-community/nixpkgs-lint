# Semantic linter for Nix using tree-sitter 🌳 + ❄️

[![asciicast](https://asciinema.org/a/483977.svg)](https://asciinema.org/a/483977)

This is a semantic linter for Nix that uses
[tree-sitter](https://tree-sitter.github.io/tree-sitter/).  Currently
we have the following detections:

- [x] `pkg-config`, `cmake` in `buildInputs`
- [x] `dontBuild = true` in `stdenv.mkDerivation`
- [x] redundant packages from `stdenv` in `nativeBuildInputs`
- [x] `pytestCheckHook` in `checkInputs`

## Features
- **Fast**: lints all of Nixpkgs in under 20 seconds
- **Semantic linting**: forget about hacking up regexes, we run
  queries directly on parse trees created by tree-sitter
- **Syntax-aware**: `nix-lint` can easily handle multi-line
  expressions, eliminates false-positives from strings and comments
  and gives exact spans for matches
- **Robust**: lint Nix files even in the presence of syntax errors
- **Hackable**: create your own lints by writing queries or by using
  TypeScript

## Usage
By default the tool will recurse through every `.nix` file in the
provided path.
```ShellSession
$ nix build 
$ ./result/bin/nix-lint <file or directory>
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

In any case, suppose we wanted to find usages of `pkg-config` in
`buildInputs`, this corresponds to the tree-sitter query

```scheme
((binding attrpath: _ @a expression: (list_expression element: (variable_expression name: _ @i)))
 (#eq? @a "buildInputs")
 (#eq? @i "pkg-config")
 ) @b
```

We use a variation of this query in JavaScript to not restrict
ourselves to when the right-hand side of the binding is not a
`list_expression` (which occurs frequently).  The JavaScript we write
is

```javascript
files.forEach(file => {
    const tree = parser.parse(readFileSync(file, "utf8"));
    let l = capturesByName(tree, pkgQuery, "l").filter((x) => x.text.includes('pkg-config'));
    if (l.length > 0) {
        console.log(file);
        console.log(l);
    }
});
```

Then we can get the output with the exact span of the right-hand side
of the binding for more processing.

```ShellSession
$ npm run lint ~/Git/forks/nixpkgs

> formula-lint@1.0.0 lint
> node index.js "/Users/siraben/Git/forks/nixpkgs"

/Users/siraben/Git/forks/nixpkgs/pkgs/applications/audio/aumix/default.nix
[
  {
    text: '[ gettext ncurses ]\n    ++ lib.optionals gtkGUI [ pkg-config gtk2 ]',
    row: 30,
    column: 16
  }
]
/Users/siraben/Git/forks/nixpkgs/pkgs/applications/audio/grandorgue/default.nix
[
  {
    text: '[ pkg-config fftwFloat alsa-lib zlib wavpack wxGTK31 udev ]\n' +
      '    ++ lib.optional jackaudioSupport libjack2',
    row: 16,
    column: 16
  }
]
```

Note that this isn't meant to be a criticism of existing parsers and
linters for Nix, but I wanted to get a linter off the ground that was
easier to write and extend gradually.

## License
This repository is licensed under the MIT license.
