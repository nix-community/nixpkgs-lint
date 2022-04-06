"use strict";
import Parser = require("tree-sitter");
// @ts-ignore
import Nix from "tree-sitter-nix";
import { readdirSync, statSync, promises as fs, PathLike } from "fs";
import { join } from "path";
const { Query } = Parser;
// @ts-ignore
import { Select } from "enquirer";

const args = process.argv.slice(2);

if (args.length != 1) {
  console.error("Usage: npm run lint <path to folder>");
  process.exit(1);
}

process.on("SIGINT", () => {
  console.log("\nExiting, bye!");
  process.exit(0);
});

const nixpkgsPath = args[0];

// Given a raw list of captures, extract the row, column and text.
function formatCaptures(captures: Parser.QueryCapture[]) {
  return captures.map((c) => {
    return {
      text: c.node.text,
      row: c.node.startPosition.row,
      column: c.node.startPosition.column,
    };
  });
}

// Get the captures corresponding to a capture name
function capturesByName(tree: Parser.Tree, query: Parser.Query, name: string) {
  return formatCaptures(
    query.captures(tree.rootNode).filter((x) => x.name == name)
  );
}

// Ignoring hidden files, get all the .nix files and traverse the tree
function recurseDir(directory: PathLike, files: string[]) {
  readdirSync(directory).forEach((file) => {
    if (/(^|\/)\.[^\/\.]/g.test(file)) return;
    const absolute = join(directory as string, file);
    if (statSync(absolute).isDirectory()) return recurseDir(absolute, files);
    else {
      if (file.split(".").pop() == "nix") return files.push(absolute);
    }
  });
  return files;
}

type QueryPred = (t: Parser.TreeCursor) => Boolean;

// https://github.com/tree-sitter/node-tree-sitter/issues/94#issuecomment-952805038
function walkCursorRec(
  cursor: Parser.TreeCursor,
  level = 0,
  p: QueryPred,
  acc: Parser.SyntaxNode[]
) {
  // top-down = handle node -> go to next node
  // depth-first = gotoFirstChild -> gotoNextSibling
  while (true) {
    if (p(cursor)) {
      acc.push(cursor.currentNode);
    }
    // go to next node
    if (cursor.gotoFirstChild()) {
      walkCursorRec(cursor, level + 1, p, acc);
      cursor.gotoParent();
    }
    if (!cursor.gotoNextSibling()) {
      return acc;
    }
  }
}

function walkCursor(cursor: Parser.TreeCursor, p: QueryPred) {
  return walkCursorRec(cursor, 0, p, [] as Parser.SyntaxNode[]);
}

type QueryPredObj = { q: Parser.Query; pred: (x: string) => Boolean };

// Find matching identifiers in tree
function queryThenWalk2(
  tree: Parser.Tree,
  capture: string,
  query: Parser.Query,
  pred: (t: string) => Boolean
) {
  return query
    .captures(tree.rootNode)
    .filter((x: Parser.QueryCapture) => x.name == capture)
    .map((x) => x.node)
    .map((x) => {
      let p1 = x.startPosition;
      let p2 = x.endPosition;
      return x.descendantsOfType("identifier", p1, p2);
    })
    .flat()
    .filter((x) => pred(x.text))
    .map((x) => {
      return {
        text: x.text,
        start: x.startPosition,
        end: x.endPosition,
      };
    });
}

const matchIdent = (t: string) => (x: string) => t == x;

const matchIdentRegex = (t: RegExp) => (x: string) => t.test(x);

async function runNew(x: QueryPredObj) {
  process.stdin.resume();
  const parser = new Parser();
  parser.setLanguage(Nix);
  let files = recurseDir(nixpkgsPath, []);
  await Promise.allSettled(
    files.map(async (file) => {
      const tree = parser.parse(await fs.readFile(file, "utf8"));
      let l = queryThenWalk2(tree, "q", x.q, x.pred);
      if (l.length > 0) {
        Promise.all(
          l.map((m) => {
            console.log(
              `${file}:${m.start.row + 1} (${m.start.row + 1},${
                m.start.column + 1
              })-(${m.end.row + 1},${m.end.column + 1})`
            );
          })
        );
      }
    })
  );
  process.exit(0);
}

const choices: {
  message: string;
  value: { q: string; pred: (t: string) => Boolean };
}[] = [
  {
    message: "pkg-config in buildInputs",
    value: {
      q: `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs") (#match? @l "pkg-config")) @q`,
      pred: matchIdent("pkg-config"),
    },
  },
  {
    message: "cmake in buildInputs",
    value: {
      q: `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs") (#match? @l "cmake")) @q`,
      pred: matchIdent("cmake"),
    },
  },
  //   {
  //     message: "dontBuild = true in stdenv.mkDerivation",
  //     value: `
  // ((apply_expression
  //     function: _ @b
  //     argument: [(rec_attrset_expression
  //                  (binding_set binding:
  //                     (binding attrpath: _ @a expression: _ @e)))
  //                (attrset_expression
  //                  (binding_set binding:
  //                     (binding attrpath: _ @a expression: _ @e)))
  //                ])
  //  (#match? @b "stdenv\.mkDerivation")
  //  (#match? @a "dontBuild")
  //  (#match? @e "true")) @q
  // `,
  //   },
  {
    message: "redundant packages from stdenv in nativeBuildInputs",
    value: {
      q: `
      ((binding attrpath: _ @a expression: _ @i)
      (#eq? @a "nativeBuildInputs")
      (#match? @i "coreutils|findutils|diffutils|gnused|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin"))
  @q`,
      pred: matchIdentRegex(
        /^(coreutils|findutils|diffutils|gnused|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin)$/
      ),
    },
  },
  {
    message: "pytestCheckHook in checkInputs",
    value: {
      q: `((binding attrpath: _ @a expression: _ @l) (#eq? @a "checkInputs") (#match? @l "pytestCheckHook")) @q`,
      pred: matchIdent("pytestCheckHook"),
    },
  },
];

const prompt = new Select({
  name: "query",
  message: "What anti-pattern do you want to debug?",
  choices: choices,
  result: (x: { q: string; pred: (t: string) => Boolean }): QueryPredObj => {
    return {
      q: new Query(Nix, x.q),
      pred: x.pred,
    };
  },
  format: (_: QueryPredObj) => "",
});

async function runDispatch(x: QueryPredObj) {
  await runNew(x);
}

prompt.run().then(runDispatch).catch(console.error);
