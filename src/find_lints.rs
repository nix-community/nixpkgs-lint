use predicates::prelude::*;

use crate::query::{AMatch, AQuery, QueryType};

use tree_sitter::{QueryCursor, Tree};

fn text_from_node(node: &tree_sitter::Node, code: &str) -> String {
    node.utf8_text(code.as_bytes()).unwrap().to_string()
}

fn print_tree(path: &str, tree: &Tree, text: &str) {
    println!("path = {path}");
    println!("text = \n{}\n", text_from_node(&tree.root_node(), text));
    println!("sexp = \n{}", tree.root_node().to_sexp());

    let cursor = &mut tree.root_node().walk();
    let travel = tree_sitter_traversal::traverse(cursor, tree_sitter_traversal::Order::Pre);
    for n in travel {
        println!("========================================================================");
        // text from node is already in the unnameds kind
        if !n.is_named() {
            println!("{n:?}");
            continue;
        }
        println!("{n:?} =");
        println!("{}", text_from_node(&n, text));
    }
}

fn get_tree(text: &str) -> Tree {
    let mut parser = tree_sitter::Parser::new();
    parser
        .set_language(tree_sitter_nix::language())
        .expect("Error loading nix grammar");

    parser
        .parse(text, None)
        .expect("Error parsing the nix code")
}

pub fn find_lints(path: &str, text: &str, queries: &Vec<AQuery>, printtree: &bool) -> Vec<AMatch> {
    let mut match_vec: Vec<AMatch> = Vec::new();

    let tree = get_tree(text);

    if *printtree {
        print_tree(path, &tree, text);
        return match_vec;
    }

    let mut whole_text = String::new();

    for q in queries {
        let query =
            tree_sitter::Query::new(tree_sitter_nix::language(), &q.query_string()).unwrap();

        let capture_id = query.capture_index_for_name("q").unwrap();

        for qm in QueryCursor::new().matches(&query, tree.root_node(), text.as_bytes()) {
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
                            "identifier" if q.what_to_pred().eval(&text_from_node(&n, text)) => {
                                match_vec.push(match_to_push(text_from_node(&n, text)));
                            }
                            _ => {}
                        },
                        QueryType::BindingAStringInsteadOfList => {
                            match n.kind() {
                                "binding" => {
                                    // TODO: make 'nixos/lib/test-driver/test_driver/machine.py' '__init__' take a list 'qemuFlags', currently it takes a str
                                    if predicate::str::starts_with("qemuFlags")
                                        .eval(&text_from_node(&n, text))
                                    {
                                        break;
                                    }
                                    whole_text = text_from_node(&n, text);
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
                                whole_text = text_from_node(&n, text);
                                match_vec.push(match_to_push(whole_text.clone()));
                                // we only want the first apply_expression
                                break;
                            }
                        }
                        QueryType::XInFormals => match n.kind() {
                            "identifier" if q.what_to_pred().eval(&text_from_node(&n, text)) => {
                                match_vec.push(match_to_push(text_from_node(&n, text)));
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

#[cfg(test)]
mod tests {
    use crate::query::QueryType::*;
    use crate::query::TypeOfFix::*;
    use crate::{
        queries::add_default_queries,
        query::{AMatch, AQuery},
    };

    use super::find_lints;

    #[test]
    fn find_lints_simple() {
        let expr = String::from(
            "{ stdenv, pkg-config, cmake }:

            stdenv.mkDerivation {
              buildInputs = [
                pkg-config
                cmake
              ];
            }",
        );
        let mut queries: Vec<AQuery> = Vec::new();
        add_default_queries(&mut queries);
        let result = find_lints("", &expr, &queries, &false);

        let expected = [
            (AMatch {
                file: "".to_string(),
                message: "build time tool in buildInputs".to_string(),
                matched: "pkg-config".to_string(),
                fix: "move this from buildInputs to nativeBuildInputs".to_string(),
                type_of_fix: Move,
                line: 5,
                column: 17,
                end_column: 27,
                byte_range: 112..122,
                list_byte_range: 94..160,
                query: AQuery {
                    name: "build time tool in buildInputs".to_string(),
                    solution: "move this from buildInputs to nativeBuildInputs".to_string(),
                    what: "cmake|makeWrapper|pkg-config|intltool|autoreconfHook".to_string(),
                    in_what: "buildInputs".to_string(),
                    type_of_query: List,
                    type_of_fix: Move,
                },
            }),
            (AMatch {
                file: "".to_string(),
                message: "build time tool in buildInputs".to_string(),
                matched: "cmake".to_string(),
                fix: "move this from buildInputs to nativeBuildInputs".to_string(),
                type_of_fix: Move,
                line: 6,
                column: 17,
                end_column: 22,
                byte_range: 139..144,
                list_byte_range: 94..160,
                query: AQuery {
                    name: "build time tool in buildInputs".to_string(),
                    solution: "move this from buildInputs to nativeBuildInputs".to_string(),
                    what: "cmake|makeWrapper|pkg-config|intltool|autoreconfHook".to_string(),
                    in_what: "buildInputs".to_string(),
                    type_of_query: List,
                    type_of_fix: Move,
                },
            }),
        ];

        assert_eq!(result, expected)
    }
}
