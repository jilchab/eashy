use std::str::FromStr;

use kdl::{KdlDocument, KdlEntry, KdlIdentifier, KdlNode, KdlValue};

pub const TITLE: &str = "\\033[1;32m";      // Bold green
pub const COMMAND: &str = "\\033[1;36m";    // Bold cyan
pub const OPTIONS: &str = "\\033[0;36m";    // Normal cyan
pub const ERROR: &str = "\\033[1;31m";      // Bold red
pub const RESET: &str = "\\033[0m";         // Reset

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ArgPrefix {
    ZeroMore,
    OneMore,
    ZeroOne,
    None,
}

impl ArgPrefix {
    pub fn extract(name: &str) -> (Self, String) {
        if let Some(first_char) = name.chars().next() {
            match first_char {
                '*' => (ArgPrefix::ZeroMore, name[1..].to_string()),
                '+' => (ArgPrefix::OneMore, name[1..].to_string()),
                '?' => (ArgPrefix::ZeroOne, name[1..].to_string()),
                _   => (ArgPrefix::None, name.to_string()),
            }
        } else {
            (ArgPrefix::None, name.to_string())
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CmdPrefix {
    UntilError,
    UntilSuccess,
    None
}

impl CmdPrefix {
    pub fn extract(name: &str) -> (Self, String) {
        if let Some(first_char) = name.chars().next() {
            match first_char {
                '&' => (CmdPrefix::UntilError, name[1..].to_string()),
                '|' => (CmdPrefix::UntilSuccess, name[1..].to_string()),
                _   => (CmdPrefix::None, name.to_string()),
            }
        } else {
            (CmdPrefix::None, name.to_string())
        }
    }
}

#[derive(Debug, Clone)]
pub struct Argument {
    pub name: String,
    pub help: String,
    pub prefix: ArgPrefix,
    pub option: Option<KdlValue>,
}

impl Argument {
    fn parse(entry: &KdlEntry) -> Self {
        let (option, name) = match entry.name() {
            Some(name) => (Some(entry.value().clone()), name.value().to_string()),
            None => (None, entry.value().to_string()),
        };

        let (mut prefix, name) = ArgPrefix::extract(&name);
        let help = entry.ty()
            .unwrap_or(&KdlIdentifier::from_str(&name.to_uppercase()).unwrap())
            .to_string()
            .trim_matches('"')
            .to_string();
        if option.is_some() && prefix != ArgPrefix::ZeroMore {
            prefix = ArgPrefix::ZeroOne;
        }
        Argument {
            name,
            prefix,
            help,
            option,
        }
    }
}

#[derive(Debug, Clone)]
pub enum Children {
    Subcmds(Vec<Command>),
    Body(Vec<String>),
}

#[derive(Debug, Clone)]
pub struct Command {
    pub name: String,
    pub prefix: CmdPrefix,
    pub description: Option<String>,
    pub arguments: Vec<Argument>,
    pub children: Children,
    pub path: Vec<String>,
}

impl Command {
    pub fn parse(node: &KdlNode, path: Option<Vec<String>>) -> Self {
        let (prefix, name) = CmdPrefix::extract(node.name().value());
        let mut path = path.unwrap_or_default();
        path.push(name.clone());
        let description = node.ty().map(|id| id.value().to_string());
        let arguments: Vec<Argument> = node
            .entries()
            .iter()
            .map(Argument::parse)
            .collect();

        let children = if let Some(children) = node.children() {
            // Check if this has subcommands or is a leaf command
            let has_nested_subcommands = children.nodes().iter().any(|n| n.children().is_some());

            if has_nested_subcommands {
                // This has subcommands
                Children::Subcmds(children
                    .nodes()
                    .iter()
                    .map(|n| Self::parse(n, Some(path.clone())))
                    .collect())
            } else {
                Children::Body(Self::parse_command_body(children))
            }
        } else {
            Children::Body(Vec::new())
        };

        Command {
            name,
            prefix,
            description,
            arguments,
            children,
            path,
        }
    }

    fn parse_command_body(children: &KdlDocument) -> Vec<String> {
        let mut command_lines = Vec::new();

        for cmd_node in children.nodes() {
            let cmd_name = cmd_node.name().value();
            let mut cmd_parts = vec![cmd_name.to_string()];

            for entry in cmd_node.entries() {
                // REMOVE QUOTES
                // if let Some(s) = entry.value().as_string() {
                //     cmd_parts.push(s.to_string());
                // } else {
                //     let part = entry.value().to_string();
                //     cmd_parts.push(part);
                // }
                let part = entry.value().to_string();
                cmd_parts.push(part);
            }
            command_lines.push(cmd_parts.join(" "));
        }

        command_lines
    }

    pub fn get_mangled_function_name(&self) -> String {
        if self.path.len() == 1 {
            self.path[0].clone()
        } else {
            format!("_{}_", self.path.join("_"))
        }
    }

    pub fn get_command_path_string(&self) -> String {
        self.path.join(" ")
    }

    pub fn get_positional_arguments(&self) -> Vec<&Argument> {
        self.arguments.iter().filter(|arg| arg.option.is_none()).collect()
    }

    pub fn get_optional_arguments(&self) -> Vec<&Argument> {
        self.arguments.iter().filter(|arg| arg.option.is_some()).collect()
    }

    pub fn get_usage_string(&self) -> String {
        let mut args = Vec::new();

        // First, check for subcommands
        if matches!(self.children, Children::Subcmds(_)) {
            args.push(format!("<subcommand>"));
        }
        // Then, add positional arguments
        for arg in &self.arguments {
            if arg.option.is_none() {
                let display_name = &arg.name;
                match arg.prefix {
                    ArgPrefix::None => args.push(format!("<{}>", display_name)),
                    ArgPrefix::ZeroMore => args.push(format!("[<{}> ...]", display_name)),
                    ArgPrefix::OneMore => args.push(format!("<{}> [<{}> ...]", display_name, display_name)),
                    ArgPrefix::ZeroOne => args.push(format!("[<{}>]", display_name)),
                }
            }
        }
        // Finally add optional arguments
        for arg in &self.arguments {
            if let Some(_) = &arg.option {
                let flag = if arg.name.len() == 1 {
                    format!("-{}", arg.name)
                } else {
                    format!("--{}", arg.name)
                };
                if matches!(arg.option, Some(kdl::KdlValue::Bool(_))) {
                    // Boolean flag
                    args.push(format!("[{}]", flag));
                } else {
                    // String option
                    args.push(format!("[{} <{}>]", flag, arg.name));
                }
            }
        }
        args.push("[-h|--help]".to_string());

        format!("{COMMAND}{} {OPTIONS}{}{RESET}",
            self.get_command_path_string(),
            if args.is_empty() { String::new() } else { args.join(" ") })
    }

    pub fn get_help_string(&self) -> String {
        let mut help_string = String::new();
        if let Some(desc) = &self.description {
            help_string.push_str(&format!("{}\n\n", desc));
        }

        help_string.push_str(&format!("{TITLE}Usage:{RESET} {}\n", self.get_usage_string()));

        if let Children::Subcmds(subcommands) = &self.children {
            help_string.push_str(&format!("\n{TITLE}Commands:{RESET}\n"));
            let width = self.get_max_width();
            for subcmd in subcommands {
                help_string.push_str(&format!("  {COMMAND}{:width$}{RESET}  {}\n", subcmd.name, subcmd.description.as_ref().unwrap_or(&String::new())));
            }
        }

        let pos_args = self.get_positional_arguments();
        if !pos_args.is_empty() {
            help_string.push_str(&format!("\n{TITLE}Positional arguments:{RESET}\n"));
            let width = self.get_max_width();
            for arg in pos_args {
                help_string.push_str(&format!("  {COMMAND}{:width$}{RESET}  {}\n", arg.name, arg.help));
            }
        }

        let opt_args = self.get_optional_arguments();
        help_string.push_str(&format!("\n{TITLE}Options:{RESET}\n"));
        let width = self.get_max_width();
        for arg in opt_args {
            let flag = if arg.name.len() == 1 {
                format!("-{}", arg.name)
            } else {
                format!("--{}", arg.name)
            };
            help_string.push_str(&format!("  {COMMAND}{:width$}{RESET}  {}\n", flag, arg.help));
        }
        help_string.push_str(&format!("  {COMMAND}{:width$}{RESET}  Show help information\n", "-h, --help"));

        help_string
    }

    pub fn get_max_width(&self) -> usize {
        let mut width = "-h, --help".len();
        if let Children::Subcmds(subcmds) = &self.children {
            for subcmd in subcmds {
                width = std::cmp::min(40, std::cmp::max(width, subcmd.name.len()));
            }
        }
        for arg in &self.arguments {
            let len = if arg.name.len() == 1 { 2 } else { arg.name.len() + 2 };
            width = std::cmp::min(40, std::cmp::max(width, len));
        }
        width
    }
}