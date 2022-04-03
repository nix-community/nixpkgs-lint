import Parser from "tree-sitter";
import Nix from "tree-sitter-nix";
import { readdirSync, statSync, promises as fs } from "fs";
import { join } from "path";
import enquirer from "enquirer";

const { Query } = Parser;
const { Select } = enquirer;

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

// Ignoring hidden files, get all the .nix files and traverse the tree
function recurseDir(directory, files) {
  readdirSync(directory).forEach((file) => {
    if (/(^|\/)\.[^\/\.]/g.test(file)) return;
    const absolute = join(directory, file);
    if (statSync(absolute).isDirectory()) return recurseDir(absolute, files);
    else {
      if (file.split(".").pop() == "nix") return files.push(absolute);
    }
  });
  return files;
}

// https://github.com/tree-sitter/node-tree-sitter/issues/94#issuecomment-952805038
function walk_cursor_rec(cursor, level = 0, p, acc) {
  // top-down = handle node -> go to next node
  // depth-first = gotoFirstChild -> gotoNextSibling
  while (true) {
    if (p(cursor)) {
      acc.push(cursor.currentNode);
    }
    // go to next node
    if (cursor.gotoFirstChild()) {
      walk_cursor_rec(cursor, level + 1, p, acc);
      cursor.gotoParent();
    }
    if (!cursor.gotoNextSibling()) {
      return acc;
    }
  }
}

const walk_cursor = (cursor, p) => walk_cursor_rec(cursor, 0, p, []);

// Combining a query with a predicate
const mkQueryPred = (query, pred) => ({
  query: new Query(Nix, query),
  pred: pred,
});

// Query the tree then walk with a predicate
function queryThenWalk(tree, queryPred) {
  return queryPred.query
    .captures(tree.rootNode)
    .filter((x) => x.name == "q")
    .map((t) => walk_cursor(t.node.walk(), queryPred.pred))
    .flat()
    .map((x) => {
      return {
        text: tree.getText(x),
        start: x.startPosition,
        end: x.endPosition,
      };
    });
}

const matchIdent = (t) => (x) => x.nodeType == "identifier" && x.nodeText == t;

const matchIdentRegex = (t) => (x) =>
  x.nodeType == "identifier" && x.nodeText.match(t);

async function run_new(queryPred) {
  process.stdin.resume();
  const parser = new Parser();
  parser.setLanguage(Nix);
  let files = recurseDir(nixpkgsPath, []);
  await Promise.allSettled(
    files.map(async (file) => {
      const tree = parser.parse(await fs.readFile(file, "utf8"));
      let l = queryThenWalk(tree, queryPred);
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

async function run_old(query) {
  process.stdin.resume();
  const parser = new Parser();
  parser.setLanguage(Nix);
  let files = recurseDir(nixpkgsPath, []);
  await Promise.allSettled(
    files.map(async (file) => {
      const tree = parser.parse(await fs.readFile(file, "utf8"));
      let l = capturesByName(tree, query, "q");
      if (l.length > 0) {
        console.log(file + ":" + (l[0].row + 1));
      }
    })
  );
  process.exit(0);
}

// TODO: refactor

// Currently a bit haphazard.  I used to only rely on the query engine
// but it was matching false positives such as comments.
const prompt = new Select({
  name: "query",
  message: "What anti-pattern do you want to debug?",
  choices: [
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
  ],
  result: (x) => ({ q: x, b: x instanceof Object }),
  format: (_) => "",
});

async function run_dispatch(r) {
  if (r.b) {
    await run_new(r.q);
  } else {
    await run_old(new Query(Nix, r.q));
  }
}

prompt.run().then(run_dispatch).catch(console.error);
