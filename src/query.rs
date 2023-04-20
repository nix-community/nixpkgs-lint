use predicates::prelude::*;
use serde::{Deserialize, Serialize};

fn pred(s: &str) -> predicates::str::RegexPredicate {
    predicate::str::is_match(format!("^({s})$")).unwrap()
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub enum QueryType {
    List,
    BindingAStringInsteadOfList,
    ArgToOptionalAList,
    XInFormals,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub enum TypeOfFix {
    Remove,
    Move,
    Change,
    ConvertToList,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct AQuery {
    pub name: String,
    pub solution: String,
    /// a regex pattern.
    /// examples: "pkg-config", "cmake|makeWrapper"
    pub what: String,
    pub in_what: String,
    pub type_of_query: QueryType,
    pub type_of_fix: TypeOfFix,
}

impl AQuery {
    pub fn query_string(&self) -> String {
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
    pub fn what_to_pred(&self) -> predicates::str::RegexPredicate {
        pred(&self.what)
    }
}

#[derive(Serialize, Debug)]
#[serde(rename_all = "camelCase")]
pub struct AMatch {
    pub file: String,
    pub message: String,
    pub matched: String,
    pub fix: String,
    pub type_of_fix: TypeOfFix,
    pub line: usize,
    // end_line is not yet used for anything because all matches will be on 1 line
    //end_line: usize,
    pub column: usize,
    pub end_column: usize,
    #[serde(skip_serializing)]
    pub byte_range: std::ops::Range<usize>,
    #[serde(skip_serializing)]
    pub list_byte_range: std::ops::Range<usize>,
    #[serde(skip_serializing)]
    pub query: AQuery,
}
