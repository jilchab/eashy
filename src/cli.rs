use anyhow::Error;
use clap::Parser;
use clap::builder::Styles;
use clap::builder::styling::{AnsiColor, Effects, Style};
use std::path::{Path, PathBuf};

const FOLDER_DIR: &str = ".eashy";

/// Expand ~ in paths to the home directory
fn expand_tilde(path: PathBuf) -> PathBuf {
    if let Some(path_str) = path.to_str()
        && let Some(stripped) = path_str.strip_prefix("~/")
        && let Some(home) = dirs::home_dir()
    {
        return home.join(stripped);
    }
    path
}

// Styling constants for clap
const HEADER: Style = AnsiColor::Green.on_default().effects(Effects::BOLD);
const USAGE: Style = AnsiColor::Green.on_default().effects(Effects::BOLD);
const LITERAL: Style = AnsiColor::Cyan.on_default().effects(Effects::BOLD);
const PLACEHOLDER: Style = AnsiColor::Cyan.on_default();
const ERROR: Style = AnsiColor::Red.on_default().effects(Effects::BOLD);
const VALID: Style = AnsiColor::Cyan.on_default().effects(Effects::BOLD);
const INVALID: Style = AnsiColor::Yellow.on_default().effects(Effects::BOLD);
const CARGO_STYLING: Styles = Styles::styled()
    .header(HEADER)
    .usage(USAGE)
    .literal(LITERAL)
    .placeholder(PLACEHOLDER)
    .error(ERROR)
    .valid(VALID)
    .invalid(INVALID);

#[derive(Parser)]
#[command(name = "eashy")]
#[command(about = "Generate shell scripts with autocompletion from KDL configuration")]
#[command(version)]
#[command(styles = CARGO_STYLING)]
pub struct Cli {
    /// KDL file to parse
    #[arg(
        short,
        long,
        value_name = "FILE",
        default_value = "~/.eashy/default.kdl"
    )]
    pub file: Option<PathBuf>,

    /// Output shell script file (use "-" for stdout)
    #[arg(short, long, value_name = "FILE", default_value = "~/.eashy/eashy.sh")]
    pub output: Option<String>,

    /// Suppress messages and sourcing instructions
    #[arg(short, long)]
    pub quiet: bool,
}

impl Cli {
    /// Parse CLI arguments
    pub fn parse() -> Self {
        Parser::parse()
    }

    /// Get the resolved input file path
    pub fn get_input_file(&self) -> Result<PathBuf, Error> {
        let path = self.file.clone().unwrap_or_else(|| {
            // This should not happen since we have a default_value, but just in case
            dirs::home_dir()
                .unwrap_or_else(|| PathBuf::from("."))
                .join(FOLDER_DIR)
                .join("default.kdl")
        });

        // Expand ~ if present
        Ok(expand_tilde(path))
    }

    /// Check if output should go to stdout
    pub fn is_stdout_output(&self) -> bool {
        self.output.as_deref() == Some("-")
    }

    /// Get the resolved output file path (None if stdout)
    pub fn get_output_file(&self) -> Result<Option<PathBuf>, Error> {
        if self.is_stdout_output() {
            Ok(None)
        } else {
            let path = self
                .output
                .as_ref()
                .map(|s| expand_tilde(PathBuf::from(s)))
                .unwrap_or_else(|| {
                    // This should not happen since we have a default_value, but just in case
                    dirs::home_dir()
                        .unwrap_or_else(|| PathBuf::from("."))
                        .join(FOLDER_DIR)
                        .join("eashy.sh")
                });

            Ok(Some(path))
        }
    }

    /// Print success messages and sourcing instructions
    pub fn print_success_message(&self, output_file: &Path) {
        if self.quiet {
            return;
        }

        println!(
            "✅ Shell script generated successfully at: {}",
            output_file.display()
        );
        // Check if already sourced in RC file
        let shell = Cli::get_shell();
        let rc_file = if shell.contains("zsh") {
            dirs::home_dir().map(|h| h.join(".zshrc"))
        } else if shell.contains("bash") {
            dirs::home_dir().map(|h| h.join(".bashrc"))
        } else if shell.contains("fish") {
            dirs::home_dir().map(|h| h.join(".config/fish/config.fish"))
        } else {
            None
        };

        let already_sourced = if let Some(rc_path) = rc_file {
            if rc_path.exists() {
                std::fs::read_to_string(&rc_path)
                    .ok()
                    .map(|content| content.contains(&format!("source {}", output_file.display())))
                    .unwrap_or(false)
            } else {
                false
            }
        } else {
            false
        };

        if already_sourced {
            return;
        }
        println!();
        println!("📋 To use the generated commands, you need to source this file:");
        println!("   source {}", output_file.display());
        println!();
        println!("🔧 To make it permanent, add this line to your shell's RC file, or run:");

        // Detect shell and provide appropriate RC file suggestion
        let shell = Cli::get_shell();
        let rc_file = if shell.contains("zsh") {
            "~/.zshrc"
        } else if shell.contains("bash") {
            "~/.bashrc"
        } else if shell.contains("fish") {
            "~/.config/fish/config.fish"
        } else {
            "your shell's configuration file"
        };

        println!("   echo 'source {}' >> {}", output_file.display(), rc_file);
        println!();
    }
    pub fn get_shell() -> String {
        std::env::var("SHELL").unwrap_or_default()
    }
}
