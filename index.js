import Parser from "tree-sitter";
import Nix from "tree-sitter-nix";
import { readFileSync, readdirSync, statSync } from "fs";
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

const textStartLength = 50;

// https://github.com/tree-sitter/node-tree-sitter/issues/94#issuecomment-952805038
function walk_cursor_rec(cursor, level = 0, p, acc) {
  // top-down = handle node -> go to next node
  // depth-first = gotoFirstChild -> gotoNextSibling
  while (true) {
    // handle this node
    const textEscaped = cursor.nodeText.replace(/\n/g, "\\n");
    const typeEscaped = cursor.nodeType.replace("\n", "\\n");
    const textStart =
      textEscaped.length < textStartLength
        ? textEscaped
        : textEscaped.slice(0, textStartLength) + " ...";
    const textLocation = `${cursor.startIndex} ${cursor.endIndex}`; // offset in utf8 chars (or offset in bytes? which is it?)
    //const textLocation = `${cursor.startPosition.row}:${cursor.startPosition.column} ${cursor.endPosition.row}:${cursor.endPosition.column}`;
    const levelString = Array.from({ length: level + 1 })
      .map((_) => "+")
      .join("");
    // console.log(`${levelString} ${textLocation} ${typeEscaped}: ${textStart}`);

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

// Over-match with query engine first then walk through and get the identifiers

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
  recurseDir(nixpkgsPath);
  Promise.all(
    files.map(async (file) => {
      const tree = parser.parse(readFileSync(file, "utf8"));
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
  recurseDir(nixpkgsPath);
  Promise.all(
    files.map(async (file) => {
      const tree = parser.parse(readFileSync(file, "utf8"));
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

function run_dispatch(r) {
  if (r.b) {
    return run_new(r.q);
  } else {
    return run_old(new Query(Nix, r.q));
  }
}

prompt.run().then(run_dispatch).catch(console.error);
