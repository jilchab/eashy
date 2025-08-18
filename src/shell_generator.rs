use kdl::KdlValue;

use crate::parser::{ArgPrefix, Argument, Children, CmdPrefix, Command, ERROR, RESET, TITLE};

/// Generate shell script from commands
pub fn generate_script(commands: &[Command]) -> String {
    let mut output = String::new();
    output.push_str(
        r#"
# Auto-generated CLI shell functions
# All modifications will be lost when terminal is reloaded

"#,
    );

    for command in commands {
        output.push_str(&generate_function(command));
        output.push_str(&generate_autocompletion(command));
    }

    output.push_str(&generate_script_end(commands));
    output
}

fn generate_function(command: &Command) -> String {
    let mut output = String::new();
    let function_name = command.get_mangled_function_name();

    output.push_str(&format!("{}() {{\n", function_name));

    // Enable word splitting for zsh compatibility (only for top-level functions)
    if command.path.len() == 1 {
        output.push_str("    setopt localoptions sh_word_split 2>/dev/null || true\n");
    }

    match &command.children {
        Children::Subcmds(subcommands) => {
            generate_subcommand_func_body(&mut output, command, subcommands);
        }
        Children::Body(command_lines) => {
            generate_leaf_func_body(&mut output, command, command_lines);
        }
    }

    output.push_str("}\n\n");

    if let Children::Subcmds(subcommands) = &command.children {
        for subcommand in subcommands {
            output.push_str(&generate_function(subcommand));
        }
    }

    output
}

fn generate_subcommand_func_body(output: &mut String, command: &Command, subcommands: &[Command]) {
    output.push_str("    local subcmd=\"$1\"\n");
    output.push_str("    if [ $# -gt 0 ]; then shift; fi\n");
    output.push_str("    case \"$subcmd\" in\n");

    // Handle help flags as special subcommands
    output.push_str("        -h|--help)\n");
    output.push_str(&format!(
        "            printf \"{}\"\n",
        escape_printf(&command.get_help_string())
    ));
    output.push_str("            return\n");
    output.push_str("            ;;\n");

    // Handle regular subcommands
    for subcommand in subcommands {
        output.push_str(&format!(
            "        {}) {} \"$@\";;\n",
            subcommand.name,
            subcommand.get_mangled_function_name()
        ));
    }

    // Handle unknown options
    output.push_str("        -*)\n");
    output.push_str(&generate_error_message(
        "Unknown option: $subcmd",
        command,
        "            ",
    ));
    output.push_str("            return 1\n");
    output.push_str("            ;;\n");

    // Handle unknown subcommands
    output.push_str("        *)\n");
    output.push_str(&generate_error_message(
        "Unknown subcommand: $subcmd",
        command,
        "            ",
    ));
    output.push_str("            return 1\n");
    output.push_str("            ;;\n");
    output.push_str("    esac\n");
}

fn generate_leaf_func_body(output: &mut String, command: &Command, command_lines: &[String]) {
    let positional_args = command.get_positional_arguments();
    let optional_args = command.get_optional_arguments();

    // Initialize variables with defaults
    for arg in &command.arguments {
        if let Some(option) = &arg.option {
            let default_value = format_default_value(option);
            output.push_str(&format!("    {}={}\n", arg.name, default_value));
        } else {
            // All positional arguments default to empty strings
            output.push_str(&format!("    {}=\"\"\n", arg.name));
        }
    }

    // Initialize positional argument tracking
    if !positional_args.is_empty() {
        output.push_str("    _pos_count=0\n\n");
    }

    // Argument parsing loop
    output.push_str("    while [ $# -gt 0 ]; do\n");
    output.push_str("        case \"$1\" in\n");

    // Handle help
    output.push_str("            -h|--help)\n");
    output.push_str(&format!(
        "                printf \"{}\"\n",
        escape_printf(&command.get_help_string())
    ));
    output.push_str("                return\n");
    output.push_str("                ;;\n");

    // Handle optional arguments
    for arg in &optional_args {
        let flag = if arg.name.len() == 1 {
            format!("-{}", arg.name)
        } else {
            format!("--{}", arg.name)
        };

        if let Some(KdlValue::Bool(b)) = &arg.option {
            output.push_str(&format!("            {})\n", flag));
            output.push_str(&format!("                {}={}\n", arg.name, !b));
            output.push_str("                shift\n");
            output.push_str("                ;;\n");
        } else {
            // String flag - requires value
            output.push_str(&format!("            {})\n", flag));
            output.push_str("                if [ $# -lt 2 ]; then\n");
            output.push_str(&generate_error_message(
                &format!("{} requires a value", flag),
                command,
                "                    ",
            ));
            output.push_str("                    return 1\n");
            output.push_str("                fi\n");
            output.push_str(&format!("                {}=\"$2\"\n", arg.name));
            output.push_str("                shift 2\n");
            output.push_str("                ;;\n");
        }
    }

    // Handle unknown options
    output.push_str("            -*)\n");
    output.push_str(&generate_error_message(
        "Unknown option: $1",
        command,
        "                ",
    ));
    output.push_str("                return 1\n");
    output.push_str("                ;;\n");

    // Handle positional arguments
    output.push_str("            *)\n");
    if positional_args.is_empty() {
        output.push_str(&generate_error_message(
            "Too many arguments",
            command,
            "                ",
        ));
        output.push_str("                return 1\n");
    } else {
        generate_positional_parsing(output, &positional_args, command);
    }
    output.push_str("                ;;\n");

    output.push_str("        esac\n");
    output.push_str("    done\n\n");

    // Validate required positional arguments
    generate_positional_validation(output, &positional_args, command);

    // Generate command execution
    output.push_str("    # Execute command\n");
    for cmd_line in command_lines {
        let mut return_early_code = String::new();
        if command.prefix == CmdPrefix::UntilError {
            return_early_code += " || return $?";
        } else if command.prefix == CmdPrefix::UntilSuccess {
            return_early_code += " && return 0";
        }
        output.push_str(&format!("    {}{}\n", cmd_line, return_early_code));
    }
}

fn generate_positional_parsing(
    output: &mut String,
    positional_args: &[&Argument],
    command: &Command,
) {
    output.push_str("                case \"$_pos_count\" in\n");

    for (index, arg) in positional_args.iter().enumerate() {
        match arg.prefix {
            ArgPrefix::None => {
                generate_single_arg_case(output, index, arg);
            }
            ArgPrefix::ZeroOne => {
                generate_optional_arg_case(output, index, arg, positional_args);
            }
            ArgPrefix::ZeroMore | ArgPrefix::OneMore => {
                generate_variadic_arg_case(output, index, arg, positional_args);
            }
        }
    }

    output.push_str("                    *)\n");
    output.push_str(&generate_error_message(
        "Too many arguments",
        command,
        "                        ",
    ));
    output.push_str("                        return 1\n");
    output.push_str("                        ;;\n");
    output.push_str("                esac\n");
}

fn generate_single_arg_case(output: &mut String, index: usize, arg: &Argument) {
    output.push_str(&format!("                    {})\n", index));
    output.push_str(&format!("                        {}=\"$1\"\n", arg.name));
    advance_position_and_shift(output);
}

fn generate_optional_arg_case(
    output: &mut String,
    index: usize,
    arg: &Argument,
    positional_args: &[&Argument],
) {
    let remaining_required: usize = positional_args
        .iter()
        .skip(index + 1)
        .map(|a| {
            if matches!(a.prefix, ArgPrefix::None | ArgPrefix::OneMore) {
                1
            } else {
                0
            }
        })
        .sum();
    output.push_str(&format!("                    {})\n", index));
    output.push_str(&format!(
        "                        if [ $# -gt {} ]; then\n",
        remaining_required
    ));
    output.push_str(&format!(
        "                            {}=\"$1\"\n",
        arg.name
    ));
    output.push_str("                            shift\n");
    output.push_str("                        fi\n");
    output.push_str("                        _pos_count=$((_pos_count + 1))\n");
    output.push_str("                        ;;\n");
}

fn generate_variadic_arg_case(
    output: &mut String,
    index: usize,
    arg: &Argument,
    positional_args: &[&Argument],
) {
    let remaining_required: usize = positional_args
        .iter()
        .skip(index + 1)
        .map(|a| {
            if matches!(a.prefix, ArgPrefix::None | ArgPrefix::OneMore) {
                1
            } else {
                0
            }
        })
        .sum();

    let condition = if index == positional_args.len() - 1 {
        "[ $# -gt 0 ]".to_string()
    } else {
        format!("[ $# -gt {} ]", remaining_required)
    };

    output.push_str(&format!("                    {})\n", index));
    output.push_str(&format!(
        "                        while {} && [ \"${{1#-}}\" = \"$1\" ]; do\n",
        condition
    ));
    output.push_str(&format!(
        "                            if [ -z \"${}\" ]; then\n",
        arg.name
    ));
    output.push_str(&format!(
        "                                {}=\"$1\"\n",
        arg.name
    ));
    output.push_str("                            else\n");
    output.push_str(&format!(
        "                                {}=\"${} $1\"\n",
        arg.name, arg.name
    ));
    output.push_str("                            fi\n");
    output.push_str("                            shift\n");
    output.push_str("                        done\n");
    output.push_str("                        _pos_count=$((_pos_count + 1))\n");
    output.push_str("                        ;;\n");
}

fn advance_position_and_shift(output: &mut String) {
    output.push_str("                        _pos_count=$((_pos_count + 1))\n");
    output.push_str("                        shift\n");
    output.push_str("                        ;;\n");
}

fn generate_positional_validation(
    output: &mut String,
    positional_args: &[&Argument],
    command: &Command,
) {
    for arg in positional_args.iter() {
        match arg.prefix {
            ArgPrefix::None => {
                output.push_str(&generate_required_validation(arg, command, "is required"));
            }
            ArgPrefix::OneMore => {
                output.push_str(&generate_required_validation(
                    arg,
                    command,
                    "is required at least once",
                ));
            }
            ArgPrefix::ZeroOne | ArgPrefix::ZeroMore => {
                // These are optional, no validation needed
            }
        }
    }
}

fn generate_required_validation(arg: &Argument, command: &Command, message: &str) -> String {
    let mut output = String::new();

    output.push_str(&format!("    if [ -z \"${}\" ]; then\n", arg.name));
    output.push_str(&generate_error_message(
        &format!("{} {}", arg.name, message),
        command,
        "        ",
    ));
    output.push_str("        return 1\n");
    output.push_str("    fi\n");
    output
}

fn format_default_value(value: &KdlValue) -> String {
    match value {
        KdlValue::Bool(val) => val.to_string(),
        KdlValue::Null => "\"\"".to_string(),
        _ => format!("\"{}\"", value),
    }
}

fn escape_printf(s: &str) -> String {
    s.replace('\\', "\\\\")
        .replace('\n', "\\n")
        .replace('"', "\\\"")
        .replace('%', "%%")
}

fn generate_autocompletion(command: &Command) -> String {
    let mut output = String::new();
    let width = command.get_max_width() + 2;

    output.push_str(&format!("_completions_{}_() {{\n", command.name));
    output.push_str("    local -a array\n");
    output.push_str("    local current=$1; shift\n");
    output.push_str("    local previous=($@)\n");
    output.push_str("    case \"${previous[@]}\" in\n");
    generate_autocompletion_case(&mut output, command);
    output.push_str("        *) ;;\n");
    output.push_str("    esac\n");
    output.push_str(&format!(
        "    array+=(\"{:<width$} Show help information\" \"{:<width$} Show help information\")\n",
        "-h:", "--help:"
    ));
    output.push_str("    for elem in \"${array[@]}\"; do\n");
    output.push_str("        if [[ $elem == \"$current\"* ]]; then echo \"$elem\"; fi\n");
    output.push_str("    done\n");
    output.push_str("}\n\n");
    output
}

fn generate_autocompletion_case(output: &mut String, command: &Command) {
    let mut comp_list = vec![];

    if let Children::Subcmds(subcommands) = &command.children {
        comp_list.extend(subcommands.iter().map(|c| {
            (
                c.name.clone() + ":",
                c.description.as_ref().unwrap_or(&String::new()).clone(),
            )
        }))
    }

    comp_list.extend(command.get_optional_arguments().iter().map(|arg| {
        (
            if arg.name.len() == 1 {
                format!("-{}:", arg.name)
            } else {
                format!("--{}:", arg.name)
            },
            if matches!(arg.option, Some(KdlValue::Bool(_))) {
                arg.help.clone()
            } else {
                format!("<{}> {}", arg.name, arg.help)
            },
        )
    }));

    if comp_list.is_empty() {
        return;
    }

    output.push_str(&format!(
        "        \"{}\") array=(\n",
        command.get_command_path_string()
    ));
    let width = command.get_max_width() + 2;
    for (name, desc) in comp_list {
        output.push_str(&format!("            \"{name:width$} {desc}\"\n"))
    }
    output.push_str("            );;\n");

    if let Children::Subcmds(ref subcommands) = command.children {
        for subcommand in subcommands {
            generate_autocompletion_case(output, subcommand);
        }
    }
}

fn generate_script_end(commands: &[Command]) -> String {
    let mut output = String::new();

    output.push_str(include_str!("include.sh"));

    output.push_str("if [ -n \"${ZSH_VERSION:-}\" ]; then autoload -Uz compinit; compinit\n");
    for command in commands {
        output.push_str(&format!("    compdef _complete_zsh {}\n", command.name));
    }
    output.push_str("elif [ -n \"${BASH_VERSION:-}\" ]; then [ \"${BASH_VERSINFO[0]}\" -lt 4 ] && no_sort=\"\" || no_sort=\"-o nosort\"\n");
    for command in commands {
        output.push_str(&format!(
            "    complete -o default $no_sort -F _complete_bash {}\n",
            command.name
        ));
    }
    output.push_str("fi\n");
    output
}

fn generate_error_message(error_msg: &str, command: &Command, indent: &str) -> String {
    let mut output = String::new();

    output.push_str(&format!(
        "{}printf \"{ERROR}Error:{RESET} {}\\n\\n\" >&2\n",
        indent, error_msg
    ));
    output.push_str(&format!(
        "{}printf \"{TITLE}Usage:{RESET} {}\\n\\n\" >&2\n",
        indent,
        escape_printf(&command.get_usage_string())
    ));
    output.push_str(&format!(
        "{}printf \"Try '{} --help' for more information.\\n\" >&2\n",
        indent,
        command.get_command_path_string()
    ));
    output
}
