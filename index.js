import Parser from "tree-sitter";
import Nix from "tree-sitter-nix";
import { readFileSync, readdirSync, statSync } from "fs";
import { join } from "path";
import enquirer from "enquirer";

const { Query } = Parser;
const { Select } = enquirer;

const args = process.argv.slice(2);

if (args.length != 1) {
  console.error("Usage: npm run lint <path to nixpkgs>");
  process.exit(1);
}

process.on("SIGINT", () => {
  console.log("\nExiting, bye!");
  process.exit(0);
});

const nixpkgsPath = join(args[0], "pkgs");

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
let files = [];
function recurseDir(Directory) {
  readdirSync(Directory).forEach((File) => {
    const Absolute = join(Directory, File);
    if (statSync(Absolute).isDirectory()) return recurseDir(Absolute);
    else return files.push(Absolute);
  });
}

const pause = () => new Promise((res) => setTimeout(res, 0));

async function run(query) {
  process.stdin.resume();
  const parser = new Parser();
  parser.setLanguage(Nix);
  recurseDir(nixpkgsPath);
  for (const file of files) {
    const tree = parser.parse(readFileSync(file, "utf8"));
    let l = capturesByName(tree, query, "q");
    await pause();
    if (l.length > 0) {
      console.log(file + ":" + (l[0].row + 1));
      // console.log(l);
    }
  }
  process.exit(0);
}

const prompt = new Select({
  name: "query",
  message: "What anti-pattern do you want to debug?",
  choices: [
    {
      message: "pkg-config in buildInputs",
      name: `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs") (#match? @l "pkg-config")) @q`,
    },
    {
      message: "dontBuild = true in stdenv.mkDerivation",
      name: `((apply_expression
    function: _ @b
    argument: [(rec_attrset_expression
                 (binding_set binding:
                    (binding attrpath: _ @a expression: _ @e)))
               (attrset_expression
                 (binding_set binding:
                    (binding attrpath: _ @a expression: _ @e)))
               ])
 (#match? @b "stdenv\.mkDerivation")
 (#match? @a "dontBuild")
 (#match? @e "true")) @q
`,
    },
    {
      message: "redundant packages from stdenv in nativeBuildInputs",
      name: `
    ((binding attrpath: _ @a expression: _ @i)
    (#eq? @a "nativeBuildInputs")
    (#match? @i "coreutils|findutils|diffutils|gnused|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin"))
     @q
    `,
    },
    {
      message: "pytestCheckHook in checkInputs",
      name: `((binding attrpath: _ @a expression: _ @l) (#eq? @a "checkInputs") (#match? @l "pytestCheckHook")) @q`,
    },
  ],
  result: (x) => new Query(Nix, x),
});

prompt.run().then(run).catch(console.error);
