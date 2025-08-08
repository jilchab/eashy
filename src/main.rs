use kdl::KdlDocument;
use std::fs;
use anyhow::Error;

use crate::parser::Command;

mod parser;
mod shell_generator;

fn main() -> Result<(), Error> {
    let filename = std::env::args()
        .nth(1)
        .ok_or(Error::msg("No KDL file specified"))?;

    let doc: KdlDocument = fs::read_to_string(filename)
        .map_err(|_| Error::msg("Failed to read KDL file"))?
        .parse()
        .map_err(|_| Error::msg("Failed to parse KDL file"))?;

    let commands = doc
        .nodes()
        .iter()
        .map(|node| Command::parse(node, None))
        .collect::<Vec<Command>>();

    let output = shell_generator::generate_script(&commands);

    fs::write("generated_cli.sh", output)?;
    Ok(())
}