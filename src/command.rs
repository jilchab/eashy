const TITLE: &str = "\\033[1;32m";      // Bold green
const COMMAND: &str = "\\033[1;36m";    // Bold cyan
const OPTIONS: &str = "\\033[0;36m";    // Normal cyan
const RESET: &str = "\\033[0m";         // Reset

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Prefix {
    UntilError,
    UntilSuccess,
    ZeroMore,
    OneMore,
    ZeroOne,
    None,
}

impl Prefix {
    pub fn extract(name: &str) -> (Self, String) {
        if let Some(first_char) = name.chars().next() {
            match first_char {
                '&' => (Prefix::UntilError, name[1..].to_string()),
                '|' => (Prefix::UntilSuccess, name[1..].to_string()),
                '*' => (Prefix::ZeroMore, name[1..].to_string()),
                '+' => (Prefix::OneMore, name[1..].to_string()),
                '?' => (Prefix::ZeroOne, name[1..].to_string()),
                _   => (Prefix::None, name.to_string()),
            }
        } else {
            (Prefix::None, name.to_string())
        }
    }
}

#[derive(Debug, Clone)]
pub struct Argument {
    pub name: String,
    pub help: String,
    pub prefix: Prefix,
    pub default_value: Option<String>,
    pub is_positional: bool,
}

#[derive(Debug, Clone)]
pub struct Command {
    pub name: String,
    pub prefix: Prefix,
    pub description: Option<String>,
    pub arguments: Vec<Argument>,
    pub command_body: Vec<String>,
    pub subcommands: Vec<Command>,
    pub path: Vec<String>,
}

impl Command {
    pub fn has_subcommands(&self) -> bool {
        !self.subcommands.is_empty()
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

    pub fn get_usage_string(&self) -> String {
        let mut args = Vec::new();

        for arg in &self.arguments {
            if arg.is_positional {
                args.push(format!("<{}>", arg.name));
            } else if let Some(default) = &arg.default_value {
                args.push(format!("[{}={}]", arg.name, default));
            } else {
                args.push(format!("<{}>", arg.name));
            }
        }
        format!("{COMMAND}{} {OPTIONS}{}{RESET}", self.get_command_path_string(), args.join(" "))
    }

    pub fn get_help_string(&self) -> String {
        let mut help_string = String::new();
        if let Some(desc) = &self.description {
            help_string.push_str(&format!("{}\n\n", desc));
        }

        help_string.push_str(&format!("{TITLE}Usage:{RESET} {}\n", self.get_usage_string()));

        if !self.arguments.is_empty() {
            help_string.push_str(&format!("{TITLE}Positional arguments:{RESET}\n"));
            for arg in &self.arguments {
                help_string.push_str(&format!("  {COMMAND}{:20}{RESET}  {}\n", arg.name, arg.help));
            }
        }

        if self.has_subcommands() {
            help_string.push_str(&format!("\n{TITLE}Commands:{RESET}\n"));

            let width = std::cmp::min(self.subcommands.iter().map(|cmd| cmd.name.len()).max().unwrap_or(0), 20);
            for subcmd in &self.subcommands {
                help_string.push_str(&format!("  {COMMAND}{:width$}{RESET}  {}\n", subcmd.name, subcmd.description.as_ref().unwrap_or(&String::new())));
            }
        }

        help_string
    }
}
