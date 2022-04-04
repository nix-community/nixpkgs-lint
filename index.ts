"use strict";
import Parser = require("tree-sitter");
import Nix from "tree-sitter-nix";
import { readdirSync, statSync, promises as fs, PathLike } from "fs";
import { join } from "path";
const { Query } = Parser;
const { Select } = require("enquirer");

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

type QueryPredObj = { query: Parser.Query; pred: QueryPred };

// Combining a query with a predicate
function mkQueryPred(query: string, pred: QueryPred): QueryPredObj {
  return {
    query: new Query(Nix, query),
    pred: pred,
  };
}

// Query the tree then walk with a predicate
function queryThenWalk(tree: Parser.Tree, queryPred: QueryPredObj) {
  return queryPred.query
    .captures(tree.rootNode)
    .filter((x: Parser.QueryCapture) => x.name == "q")
    .map((t: Parser.QueryCapture) => walkCursor(t.node.walk(), queryPred.pred))
    .flat()
    .map((x) => {
      return {
        text: x.text,
        start: x.startPosition,
        end: x.endPosition,
      };
    });
}

const matchIdent = (t: string) => (x: Parser.TreeCursor) =>
  x.nodeType == "identifier" && x.nodeText == t;

const matchIdentRegex = (t: RegExp) => (x: Parser.TreeCursor) =>
  x.nodeType == "identifier" && t.test(x.nodeText);

async function runNew(
  x: { query: Parser.Query; pred: QueryPred } | Parser.Query
) {
  process.stdin.resume();
  const parser = new Parser();
  parser.setLanguage(Nix);
  let files = recurseDir(nixpkgsPath, []);
  if ("pred" in x) {
    await Promise.allSettled(
      files.map(async (file) => {
        const tree = parser.parse(await fs.readFile(file, "utf8"));
        let l = queryThenWalk(tree, x);
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
  } else {
    await Promise.allSettled(
      files.map(async (file) => {
        const tree = parser.parse(await fs.readFile(file, "utf8"));
        let l = capturesByName(tree, x, "q");
        if (l.length > 0) {
          console.log(file + ":" + (l[0].row + 1));
        }
      })
    );
  }
  process.exit(0);
}

const choices: { message: string; value: string | QueryPredObj }[] = [
  {
    message: "pkg-config in buildInputs",
    value: mkQueryPred(
      `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs") (#match? @l "pkg-config")) @q`,
      matchIdent("pkg-config")
    ),
  },
  {
    message: "cmake in buildInputs",
    value: mkQueryPred(
      `((binding attrpath: _ @a expression: _ @l) (#eq? @a "buildInputs") (#match? @l "cmake")) @q`,
      matchIdent("cmake")
    ),
  },
  {
    message: "dontBuild = true in stdenv.mkDerivation",
    value: `
((apply_expression
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
    value: mkQueryPred(
      `
    ((binding attrpath: _ @a expression: _ @i)
    (#eq? @a "nativeBuildInputs")
    (#match? @i "coreutils|findutils|diffutils|gnused|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin"))
     @q`,
      matchIdentRegex(
        /^(coreutils|findutils|diffutils|gnused|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin)$/
      )
    ),
  },
  {
    message: "pytestCheckHook in checkInputs",
    value: mkQueryPred(
      `((binding attrpath: _ @a expression: _ @l) (#eq? @a "checkInputs") (#match? @l "pytestCheckHook")) @q`,
      matchIdent("pytestCheckHook")
    ),
  },
];
const prompt = new Select({
  name: "query",
  message: "What anti-pattern do you want to debug?",
  choices: choices,
  result: (x: QueryPredObj | string) =>
    typeof x === "string" ? new Query(Nix, x) : x,
  format: (_: QueryPredObj | string) => "",
});

async function runDispatch(x: QueryPredObj | Parser.Query) {
  await runNew(x);
}

prompt.run().then(runDispatch).catch(console.error);
