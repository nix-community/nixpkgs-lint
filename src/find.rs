use std::path::PathBuf;

use walkdir::{DirEntry, WalkDir};

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

pub fn find_nix_files(path: &PathBuf) -> Vec<String> {
    WalkDir::new(path)
        .into_iter()
        .filter_entry(|e| !is_hidden(e))
        .filter_map(|entry| entry.ok())
        .filter(is_nix_file)
        .map(|f| f.path().to_str().unwrap().to_owned())
        .collect()
}
