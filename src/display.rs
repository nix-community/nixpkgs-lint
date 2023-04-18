use std::fs::read_to_string;

use crate::query::{AMatch, QueryType};
use ariadne::{Color, Label, Report as CliReport, ReportKind as CliReportKind, Source};

#[derive(Clone, Debug, clap::ValueEnum)]
pub enum DisplayFormats {
    Ariadne,
    Json,
}

pub fn print_matches(display_format: DisplayFormats, match_vec: Vec<AMatch>) {
    match display_format {
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
                            Label::new((src_id, m.list_byte_range.start..m.list_byte_range.end))
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
}
