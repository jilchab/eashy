use crate::command::{Command, Prefix};

/// Generate shell script from commands
pub fn generate_script(commands: &[Command]) -> String {
    let mut output = String::new();
    output.push_str(r#"
# Auto-generated CLI shell functions
# All modifications will be lost when terminal is reloaded

"#);

    for command in commands {
        output.push_str(&generate_function(command));
    }

    output
}

fn generate_function(command: &Command) -> String {
    let mut output = String::new();
    let command_path = command.get_command_path_string();
    let function_name = command.get_mangled_function_name();

    output.push_str(&format!("function {}() {{\n", function_name));

    // Generate help handling
    output.push_str("    for arg in \"$@\"; do\n");
    if command.has_subcommands() {
        output.push_str("        if [[ \"$arg\" != -* ]]; then break; fi\n");
    }
    output.push_str("        if [[ \"$arg\" == \"-h\" || \"$arg\" == \"--help\" ]]; then\n");
    output.push_str(&format!("            printf \"{}\"\n", command.get_help_string()));
    output.push_str("            return\n");
    output.push_str("        fi\n");
    output.push_str("    done\n");


    if command.has_subcommands() {
        output.push_str("    local subcmd=\"$1\"\n");
        output.push_str("    if [[ $# -gt 0 ]]; then shift; fi\n");
        output.push_str("    case \"$subcmd\" in\n");
        for subcommand in &command.subcommands {
            output.push_str(&format!("        {}) {} \"$@\";;\n", subcommand.name, subcommand.get_mangled_function_name()));
        }
        output.push_str("        *)\n");
        output.push_str("            printf \"Unknown subcommand: $subcmd\\n\"\n");
        output.push_str(&format!("            printf \"Use '{} --help' for available commands.\\n\"\n", command_path));
        output.push_str("            ;;\n");
        output.push_str("    esac\n");
    } else {
        // Generate argument assignments
        let mut pos_index = 1;
        for arg in &command.arguments {
            if arg.is_positional {
                output.push_str(&format!("    local {}=\"${}\"\n", arg.name, pos_index));
                pos_index += 1;
            } else if let Some(default) = &arg.default_value {
                output.push_str(&format!("    local {}=\"${{{}:-{}}}\"\n", arg.name, pos_index, default));
                pos_index += 1;
            } else {
                output.push_str(&format!("    local {}=\"${}\"\n", arg.name, pos_index));
                pos_index += 1;
            }
        }

        // Generate command execution
        for cmd_line in &command.command_body {
            let mut return_early_code = String::new();
            if command.prefix == Prefix::UntilError {
                return_early_code += " || return $?";
            } else if command.prefix == Prefix::UntilSuccess {
                return_early_code += " && return 0";
            }
            output.push_str(&format!("    {}{}\n", cmd_line, return_early_code));
        }
    }
    output.push_str("}\n\n");

    if command.has_subcommands() {
        for subcommand in &command.subcommands {
            output.push_str(&generate_function(subcommand));
        }
    }

    output
}
