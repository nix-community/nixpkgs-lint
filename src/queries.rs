use crate::query::{AQuery, QueryType, TypeOfFix};

pub fn add_default_queries(queries: &mut Vec<AQuery>) {
    let mut default_queries = vec![
        (AQuery {
            name: "build time tool in buildInputs".to_string(),
            solution: "move this from buildInputs to nativeBuildInputs".to_string(),
            what: "cmake|makeWrapper|pkg-config|intltool|autoreconfHook".to_string(),
            in_what: "buildInputs".to_string(),
            type_of_query: QueryType::List,
            type_of_fix: TypeOfFix::Move,
        }),
        (AQuery {
            name: "*Flags not a list".to_string(),
            solution: "convert to a list".to_string(),
            what: String::new(),
            in_what: "Flags".to_string(),
            type_of_query: QueryType::BindingAStringInsteadOfList,
            type_of_fix: TypeOfFix::ConvertToList,
        }),
        (AQuery {
            name: "Arg to lib.optional is a list".to_string(),
            solution: "change lib.optional to lib.optionals".to_string(),
            what: String::new(),
            in_what: String::new(),
            type_of_query: QueryType::ArgToOptionalAList,
            type_of_fix: TypeOfFix::Change,
        }),
    ];

    queries.append(&mut default_queries);
}

pub fn add_unfinished_queries(queries: &mut Vec<AQuery>) {
    let mut unfinished_queries = vec![
        (AQuery {
            name: "redundant package from stdenv in nativeBuildInputs".to_string(),
            solution: "remove this from nativeBuildInputs".to_string(),
            what: r"coreutils|findutils|diffutils|gnugrep|gawk|gnutar|gzip|bzip2\.bin|gnumake|bash|patch|xz\.bin|file".to_string(),
            in_what: "nativeBuildInputs".to_string(),
            type_of_query: QueryType::List,
            type_of_fix: TypeOfFix::Remove,
        }),
    ];

    queries.append(&mut unfinished_queries);
}
