import Parser from "tree-sitter";
import Nix from "tree-sitter-nix";
import { readFileSync, readdirSync, statSync } from "fs";
import { join } from "path"

const { Query } = Parser;

const args = process.argv.slice(2);

if (args.length != 1) {
  console.error("Usage: npm run lint <path to nixpkgs>");
  process.exit(1);
}


const nixpkgsPath = join(args[0],'pkgs');

const parser = new Parser();
parser.setLanguage(Nix);

// Query for pkg-config in buildInputs
const pkgQuery = new Query(
  Nix,
    `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs")) @b`
);

// Given a raw list of captures, extract the row, column and text.
function formatCaptures(tree, captures) {
  return captures.map((c) => {
    const node = c.node;
    delete c.node;
    c.text = tree.getText(node);
    c.row = node.startPosition.row;
    c.column = node.startPosition.column;
    return c;
  });
}

// Get the captures corresponding to a capture name
function capturesByName(tree, query, name) {
  return formatCaptures(
    tree,
    query.captures(tree.rootNode).filter((x) => x.name == name)
  ).map((x) => {
    delete x.name;
    return x;
  });
}

// Get all the .nix files in pkgs/ and traverse the tree
let files = []
function recurseDir(Directory) {
    readdirSync(Directory).forEach(File => {
        const Absolute = join(Directory, File);
        if (statSync(Absolute).isDirectory()) return recurseDir(Absolute);
        else return files.push(Absolute);
    });
}

recurseDir(nixpkgsPath);

// Lint each file in Nixpkgs
files.forEach(file => {
    const tree = parser.parse(readFileSync(file, "utf8"));
    let l = capturesByName(tree, pkgQuery, "l").filter((x) => x.text.includes('pkg-config'));
    if (l.length > 0) {
        console.log(file);
        console.log(l);
    }
});
