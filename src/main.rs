use std::{env::current_dir, fs::read_to_string, path::PathBuf, process::ExitCode};

use clap::{crate_version, Parser};
use display::{print_matches, DisplayFormats};
use find::find_nix_files;
use find_lints::find_lints;
use indicatif::{ParallelProgressIterator, ProgressBar};
use queries::{add_default_queries, add_unfinished_queries};
use query::{AMatch, AQuery};
use rayon::prelude::*;

mod display;
mod find;
mod find_lints;
mod queries;
mod query;

fn main() -> ExitCode {
    let args = Opt::parse();
    let mut match_vec: Vec<AMatch> = Vec::new();

    let mut queries: Vec<AQuery> = Vec::new();

    add_default_queries(&mut queries);

    if args.include_unfinished_lints {
        add_unfinished_queries(&mut queries);
    };

    for mut path in args.file {
        if let Ok(false) = &path.try_exists() {
            eprintln!("path '{}' does not exist", path.to_string_lossy());
            return ExitCode::FAILURE;
        }
        if path.to_string_lossy() == "." {
            path = current_dir().unwrap();
        }
        let entries = find_nix_files(&path);
        let length: u64 = entries.len().try_into().unwrap();
        let mut pb = ProgressBar::hidden();
        if length > 1000 {
            pb = ProgressBar::new(length);
        }

        match_vec.par_extend(entries.into_par_iter().progress_with(pb).flat_map(|entry| {
            find_lints(
                &entry,
                read_to_string(&entry).unwrap().trim(),
                &queries,
                &args.node_debug,
            )
        }));
    }

    if !match_vec.is_empty() {
        print_matches(&args.format, &match_vec);
        return ExitCode::FAILURE;
    }

    ExitCode::SUCCESS
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
