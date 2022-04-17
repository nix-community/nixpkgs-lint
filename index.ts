"use strict";
import Parser = require("tree-sitter");
// @ts-ignore
import Nix from "tree-sitter-nix";
import { readdirSync, statSync, promises as fs, PathLike } from "fs";
import { join } from "path";
const { Query } = Parser;
// @ts-ignore
import { Select } from "enquirer";

import commandLineArgs from "command-line-args";

const optionDefinitions = [
  { name: "json", type: Boolean },
  { name: "src", type: String, multiple: true, defaultOption: true },
];

const options = commandLineArgs(optionDefinitions);

process.on("SIGINT", () => {
  console.log("\nExiting, bye!");
  process.exit(0);
});

if (options.src === undefined) {
  console.error("Usage: npm run lint [--json] <list of paths>");
  process.exit(1);
}
const src = options.src;

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
async function recurseDir(directory: PathLike, files: string[]) {
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
    .map((x) =>
      x.descendantsOfType("identifier", x.startPosition, x.endPosition)
    )
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
  let files = (
    await Promise.all(
      src.map((dir: PathLike) =>
        statSync(dir).isDirectory() ? recurseDir(dir, []) : [dir]
      )
    )
  ).flat();
  let res = [];
  await Promise.allSettled(
    files.map(async (file) => {
      const tree = parser.parse(await fs.readFile(file, "utf8"));
      let l = queryThenWalk2(tree, "q", x.q, x.pred);
      if (l.length > 0) {
        Promise.all(
          l.map((m) => {
            let data = {
              file: file,
              start: { row: m.start.row + 1, column: m.start.column + 1 },
              end: { row: m.end.row + 1, column: m.end.column + 1 },
            };
            if (options.json) {
              res.push(data);
            } else {
              console.log(
                `${data.file}:${data.start.row} (${data.start.row},${m.start.column})-(${data.end.row},${data.end.column})`
              );
            }
          })
        );
      }
    })
  );
  if (options.json) {
    console.log(res);
  }
  process.exit(0);
}

type QueryTemplate = { q: string; pred: (t: string) => Boolean };

function realize(x: QueryTemplate): QueryPredObj {
  return {
    q: new Query(Nix, x.q),
    pred: x.pred,
  };
}

const choices: { message: string; value: QueryTemplate }[] = [
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
  result: realize,
  format: (_: QueryPredObj) => "",
});

async function runDispatch(x: QueryPredObj) {
  await runNew(x);
}

prompt.run().then(runDispatch).catch(console.error);
