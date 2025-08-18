use anyhow::Error;
use kdl::KdlDocument;
use std::fs;
use std::io::{self, Write};

use crate::cli::Cli;
use crate::parser::Command;

mod cli;
mod parser;
mod shell_generator;

fn main() -> Result<(), Error> {
    let cli = Cli::parse();
    let input_file = cli.get_input_file()?;
    let output_file = cli.get_output_file()?;

    // Create directory for output file if needed
    if let Some(ref file) = output_file
        && let Some(parent) = file.parent()
    {
        std::fs::create_dir_all(parent)?;
    }

    // Read and parse the KDL file
    let doc: KdlDocument = fs::read_to_string(&input_file)
        .map_err(|e| {
            Error::msg(format!(
                "Failed to read KDL file '{}': {}",
                input_file.display(),
                e
            ))
        })?
        .parse()
        .map_err(|e| {
            Error::msg(format!(
                "Failed to parse KDL file '{}': {}",
                input_file.display(),
                e
            ))
        })?;

    let commands = doc
        .nodes()
        .iter()
        .map(|node| Command::parse(node, None))
        .collect::<Vec<Command>>();

    let output = shell_generator::generate_script(&commands);

    // Write output to stdout or file
    if cli.is_stdout_output() {
        print!("{}", output);
        io::stdout()
            .flush()
            .map_err(|e| Error::msg(format!("Failed to flush stdout: {}", e)))?;
    } else {
        let file = output_file.unwrap();
        fs::write(&file, output).map_err(|e| {
            Error::msg(format!(
                "Failed to write output file '{}': {}",
                file.display(),
                e
            ))
        })?;

        cli.print_success_message(&file);
    }

    Ok(())
}
