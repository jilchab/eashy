use kdl::KdlDocument;
use std::fs;
use anyhow::Error;

mod command;
mod shell_generator;
mod parser;

fn main() -> Result<(), Error> {
    // Read the KDL file specified as the first command line argument
    let filename = std::env::args()
        .nth(1)
        .ok_or(Error::msg("No KDL file specified"))?;

    let doc: KdlDocument = fs::read_to_string(filename)
        .map_err(|_| Error::msg("Failed to read KDL file"))?
        .parse()
        .map_err(|_| Error::msg("Failed to parse KDL file"))?;

    // Convert KDL nodes to command structures
    let commands = parser::parse_commands(&doc);
    dbg!(&commands);
    // Generate shell script
    let output = shell_generator::generate_script(&commands);

    fs::write("generated_cli.sh", output)?;
    Ok(())
}