use anyhow::Error;
use clap::Parser;
use kdl::KdlDocument;
use std::fs;
use std::path::PathBuf;

use crate::parser::Command;

mod parser;
mod shell_generator;

const FOLDER_DIR: &str = ".eashy";

#[derive(Parser)]
#[command(name = "eashy")]
#[command(about = "Generate shell scripts with autocompletion from KDL configuration")]
#[command(version)]
struct Cli {
    #[arg(short, long, value_name = "FILE")]
    file: Option<PathBuf>,
    #[arg(short, long, value_name = "FILE")]
    output: Option<PathBuf>,
}

fn get_default_paths() -> Result<(PathBuf, PathBuf), Error> {
    let eashy_dir = dirs::home_dir()
        .ok_or(Error::msg("Could not determine home directory"))?
        .join(FOLDER_DIR);

    let default_input = eashy_dir.join("default.kdl");
    let default_output = eashy_dir.join("eashy.sh");

    Ok((default_input, default_output))
}

fn main() -> Result<(), Error> {
    let cli = Cli::parse();

    let (default_input, default_output) = get_default_paths()?;
    let input_file = cli.file.unwrap_or(default_input);
    let output_file = cli.output.unwrap_or(default_output);
    if let Some(parent) = output_file.parent() {
        std::fs::create_dir_all(parent)?;
    }

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

    // Write the output file
    fs::write(&output_file, output).map_err(|e| {
        Error::msg(format!(
            "Failed to write output file '{}': {}",
            output_file.display(),
            e
        ))
    })?;

    // Success message with sourcing instructions
    println!("Successfully generated at: {}", output_file.display());
    println!("To use the generated commands, you need to source this file:");
    println!("   source {}", output_file.display());
    println!("To make it permanent, add this line to your .bashrc/.zshrc");

    Ok(())
}
