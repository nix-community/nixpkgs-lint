use std::{env::current_dir, fs::read_to_string, path::PathBuf, process::ExitCode};

use clap::{crate_version, Parser};
use indicatif::{ParallelProgressIterator, ProgressBar};
use predicates::prelude::*;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use tree_sitter::QueryCursor;
use walkdir::{DirEntry, WalkDir};

use ariadne::{Color, Label, Report as CliReport, ReportKind as CliReportKind, Source};

fn text_from_node(node: &tree_sitter::Node, code: &str) -> String {
    node.utf8_text(code.as_bytes()).unwrap().to_string()
}

#[derive(Serialize, Deserialize, Debug, Clone)]
enum QueryType {
    List,
    BindingAStringInsteadOfList,
    ArgToOptionalAList,
    XInFormals,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
enum TypeOfFix {
    Remove,
    Move,
    Change,
    ConvertToList,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
struct AQuery {
    name: String,
    solution: String,
    /// a regex pattern.
    /// examples: "pkg-config", "cmake|makeWrapper"
    what: String,
    in_what: String,
    type_of_query: QueryType,
    type_of_fix: TypeOfFix,
}

impl AQuery {
    fn query_string(&self) -> String {
        match self.type_of_query {
            QueryType::List => format!(
                "(
                    (binding attrpath: _ @a expression: _ @l)
                    (#eq? @a \"{}\")
                    (#match? @l \"{}\")
                ) @q",
                self.in_what, self.what
            ),
            QueryType::BindingAStringInsteadOfList => format!(
                "(
                    (binding attrpath: _ @a expression: (string_expression) @l)
                    (#match? @a \"{}\")
                ) @q",
                self.in_what
            ),
            QueryType::ArgToOptionalAList => String::from(
                "(
                    (apply_expression
                        function:
                            (apply_expression
                              function: (_ (_) @a)
                            )
                        argument: (list_expression) @l
                    )
                    (match? @a \"^optional$\")
                ) @q",
            ),
            QueryType::XInFormals => format!(
                "(
                    (function_expression
                        formals: (formals
                            (formal
                                (identifier) @q))
                    )
                    (match? @q \"{}\")
                )",
                self.what
            ),
        }
    }
    fn what_to_pred(&self) -> predicates::str::RegexPredicate {
        pred(&self.what)
    }
}

#[derive(Serialize, Debug)]
#[serde(rename_all = "camelCase")]
struct AMatch {
    file: String,
    message: String,
    matched: String,
    fix: String,
    type_of_fix: TypeOfFix,
    line: usize,
    // end_line is not yet used for anything because all matches will be on 1 line
    //end_line: usize,
    column: usize,
    end_column: usize,
    #[serde(skip_serializing)]
    byte_range: std::ops::Range<usize>,
    #[serde(skip_serializing)]
    list_byte_range: std::ops::Range<usize>,
    #[serde(skip_serializing)]
    query: AQuery,
}

fn find_lints(path: &str, queries: &Vec<AQuery>, printtree: bool) -> Vec<AMatch> {
    let code = read_to_string(&path).unwrap().trim().to_owned();
    let mut parser = tree_sitter::Parser::new();
    parser
        .set_language(tree_sitter_nix::language())
        .expect("Error loading nix grammar");

    let tree = parser
        .parse(&code, None)
        .expect("Error parsing the nix code");

    let mut match_vec: Vec<AMatch> = Vec::new();

    if printtree {
        println!("path = {}", path);
        println!("text = \n{}\n", text_from_node(&tree.root_node(), &code));
        println!("sexp = \n{}", tree.root_node().to_sexp());

        let cursor = &mut tree.root_node().walk();
        let travel = tree_sitter_traversal::traverse(cursor, tree_sitter_traversal::Order::Pre);
        for n in travel {
            println!("========================================================================");
            // text from node is already in the unnameds kind
            if !n.is_named() {
                println!("{:?}", n);
                continue;
            }
            println!("{:?} =", n);
            println!("{}", text_from_node(&n, &code));
        }
        return match_vec;
    }

    let mut whole_text = String::new();

    for q in queries {
        let query =
            tree_sitter::Query::new(tree_sitter_nix::language(), &q.query_string()).unwrap();

        let capture_id = query.capture_index_for_name("q").unwrap();

        for qm in QueryCursor::new().matches(&query, tree.root_node(), code.as_bytes()) {
            let mut list_range: std::ops::Range<usize> = 0..0;

            if let Some(node) = qm.nodes_for_capture_index(capture_id).next() {
                let cursor = &mut node.walk();
                // Lists need recursive traversal
                let travel =
                    tree_sitter_traversal::traverse(cursor, tree_sitter_traversal::Order::Pre);
                for n in travel {
                    if !n.is_named() {
                        continue;
                    }
                    let match_to_push = |matched| AMatch {
                        file: path.to_owned(),
                        message: q.name.to_owned(),
                        matched,
                        fix: q.solution.to_owned(),
                        type_of_fix: q.type_of_fix.to_owned(),
                        line: n.start_position().row + 1,
                        //end_line: n.end_position().row + 1,
                        column: n.start_position().column + 1,
                        end_column: n.end_position().column + 1,
                        byte_range: n.byte_range(),
                        list_byte_range: list_range.to_owned(),
                        query: q.to_owned(),
                    };
                    match q.type_of_query {
                        QueryType::List => match n.kind() {
                            "list_expression" => {
                                list_range = n.byte_range();
                                continue;
                            }
                            "identifier" if q.what_to_pred().eval(&text_from_node(&n, &code)) => {
                                match_vec.push(match_to_push(text_from_node(&n, &code)));
                            }
                            _ => {}
                        },
                        QueryType::BindingAStringInsteadOfList => {
                            match n.kind() {
                                "binding" => {
                                    // TODO: make 'nixos/lib/test-driver/test_driver/machine.py' '__init__' take a
                                    // list 'qemuFlags', currently it takes a str
                                    if predicate::str::starts_with("qemuFlags")
                                        .eval(&text_from_node(&n, &code))
                                    {
                                        break;
                                    }
                                    whole_text = text_from_node(&n, &code);
                                }
                                "string_expression" => {
                                    match_vec.push(match_to_push(whole_text.clone()));
                                    // we only want the first string_expression(whole string) and not the
                                    // possible string_expression's in interpolation
                                    break;
                                }
                                _ => {}
                            }
                        }
                        QueryType::ArgToOptionalAList => {
                            if n.kind() == "apply_expression" {
                                whole_text = text_from_node(&n, &code);
                                match_vec.push(match_to_push(whole_text.clone()));
                                // we only want the first apply_expression
                                break;
                            }
                        }
                        QueryType::XInFormals => match n.kind() {
                            "identifier" if q.what_to_pred().eval(&text_from_node(&n, &code)) => {
                                match_vec.push(match_to_push(text_from_node(&n, &code)));
                            }
                            _ => {}
                        },
                    }
                }
            }
        }
    }
    match_vec
}

fn pred(s: &str) -> predicates::str::RegexPredicate {
    predicate::str::is_match(format!("^({})$", s)).unwrap()
}

fn is_hidden(entry: &DirEntry) -> bool {
    entry
        .file_name()
        .to_str()
        .map(|s| s.starts_with('.'))
        .unwrap_or(false)
}

fn is_nix_file(entry: &DirEntry) -> bool {
    entry
        .file_name()
        .to_str()
        .map(|s| s.ends_with(".nix"))
        .unwrap_or(false)
}

fn find_nix_files(path: PathBuf) -> Vec<String> {
    WalkDir::new(path)
        .into_iter()
        .filter_entry(|e| !is_hidden(e))
        .filter_map(|entry| entry.ok())
        .filter(is_nix_file)
        .map(|f| f.path().to_str().unwrap().to_owned())
        .collect()
}

fn main() -> ExitCode {
    let args = Opt::parse();
    let mut match_vec: Vec<AMatch> = Vec::new();

    let mut queries = vec![
        //(AQuery {
        //    name: "redundant package from stdenv in nativeBuildInputs".to_string(),
        //    solution: "remove this from nativeBuildInputs".to_string(),
        //    what: r"coreutils|findutils|diffutils|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin|file".to_string(),
        //    in_what: "nativeBuildInputs".to_string(),
        //    type_of_query: QueryType::List,
        //    type_of_fix: TypeOfFix::Remove,
        //}),
        (AQuery {
            name: "build time tool in buildInputs".to_string(),
            solution: "move this from buildInputs to nativeBuildInputs".to_string(),
            what: "cmake|makeWrapper|pkg-config|intltool|autoreconfHook".to_string(),
            in_what: "buildInputs".to_string(),
            type_of_query: QueryType::List,
            type_of_fix: TypeOfFix::Move,
        }),
    ];
    if args.include_unfinished_lints {
        queries.push(AQuery {
            name: "*Flags not a list".to_string(),
            solution: "convert to a list".to_string(),
            what: "".to_string(),
            in_what: "Flags".to_string(),
            type_of_query: QueryType::BindingAStringInsteadOfList,
            type_of_fix: TypeOfFix::ConvertToList,
        });
        queries.push(AQuery {
            name: "Arg to lib.optional is a list".to_string(),
            solution: "change lib.optional to lib.optionals".to_string(),
            what: "".to_string(),
            in_what: "".to_string(),
            type_of_query: QueryType::ArgToOptionalAList,
            type_of_fix: TypeOfFix::Change,
        });
    }

    for mut path in args.file {
        if let Ok(false) = &path.try_exists() {
            eprintln!("path '{}' does not exist", path.to_string_lossy());
            return ExitCode::FAILURE;
        }
        if path.to_string_lossy() == "." {
            path = current_dir().unwrap();
        }
        let entries = find_nix_files(path);
        let length: u64 = entries.len().try_into().unwrap();
        let mut pb = ProgressBar::hidden();
        if length > 1000 {
            pb = ProgressBar::new(entries.len().try_into().unwrap());
        }

        match_vec.par_extend(
            entries
                .into_par_iter()
                .progress_with(pb)
                .flat_map(|entry| find_lints(&entry, &queries, args.node_debug)),
        );
    }

    if !match_vec.is_empty() {
        match args.format {
            DisplayFormats::Json => {
                let serialized_match = serde_json::to_string_pretty(&match_vec).unwrap();
                println!("{}", serialized_match);
            }
            DisplayFormats::Ariadne => {
                for m in &match_vec {
                    let src_id = m.file.as_str();
                    let mut report =
                        CliReport::build(CliReportKind::Advice, src_id, m.byte_range.start)
                            .with_message(&m.message)
                            .with_label(
                                Label::new((src_id, m.byte_range.start..m.byte_range.end))
                                    .with_message(&m.fix)
                                    .with_color(Color::Magenta),
                            );

                    match m.query.type_of_query {
                        QueryType::List => {
                            report = report.with_label(
                                Label::new((
                                    src_id,
                                    m.list_byte_range.start..m.list_byte_range.end,
                                ))
                                .with_message("part of this list")
                                .with_color(Color::Blue),
                            );
                        }
                        QueryType::BindingAStringInsteadOfList => (),
                        QueryType::ArgToOptionalAList => (),
                        QueryType::XInFormals => (),
                    };

                    report
                        .finish()
                        .print((
                            src_id,
                            Source::from(read_to_string(&m.file).unwrap().trim().to_owned()),
                        ))
                        .unwrap();
                }
            }
        }
        return ExitCode::FAILURE;
    }

    ExitCode::SUCCESS
}

#[derive(Clone, Debug, clap::ValueEnum)]
enum DisplayFormats {
    Ariadne,
    Json,
}

#[derive(Parser, Debug)]
#[clap(version = crate_version!())]
struct Opt {
    /// Files or directories
    #[clap(value_name = "FILES/DIRECTORIES")]
    file: Vec<PathBuf>,

    /// Output format
    #[clap(value_enum, long, default_value_t = DisplayFormats::Ariadne)]
    format: DisplayFormats,

    /// debug nodes
    #[clap(long = "node-debug")]
    node_debug: bool,

    /// use lints which haven't been fixed in nixpkgs yet
    #[clap(long = "include-unfinished-lints")]
    include_unfinished_lints: bool,

    /// enable if running in nixpkgs ci
    #[clap(
        conflicts_with = "include_unfinished_lints",
        long = "running-in-nixpkgs-ci"
    )]
    running_in_nixpkgs_ci: bool,
}
