# Eashy

**No more hassle writing shell functions! Easy subcommands and help documentation**

Eashy is a command-line tool that generates shell functions with subcommands and integrated help documentation from simple KDL configuration files. Say goodbye to manually writing complex shell functions and hello to declarative command definitions!

## Features

- **Simple KDL syntax**: Define commands using the human-friendly KDL format
- **Automatic help generation**: Built-in `--help` support for all commands and subcommands
- **Nested subcommands**: Support for multiple levels of command hierarchies
- **Beautiful output**: Colorized help text and command output
- **Shell function generation**: Automatically generates optimized shell functions
- **Auto complete**: Built-in support for autocomplete for bash/zsh

## Installation

For Linux or MacOS:
```bash
curl -fsSL https://github.com/jilchab/eashy/raw/main/install.sh | sh
```

Or using Cargo:
```bash
cargo install eashy
```

## Quick Start

1. Create a KDL file defining your commands (e.g., `commands.kdl`):

```kdl
("Python venv management") \
venv {
    ("Create a new virtual environment")\
    init {
        python -m venv ".venv"
        source ".venv/bin/activate"
        echo "Activated virtual environment, version: $(python --version)"
    }

    ("Activate the virtual environment")\
    activate {
        source ".venv/bin/activate" && \
        echo "Activated virtual environment, version: $(python --version)" || \
        echo "Failed to activate virtual environment. Make sure .venv exists."
    }

    ("Deactivate the virtual environment")\
    deactivate {
        deactivate
        echo "Deactivated virtual environment"
    }
}
```

2. Generate shell functions:

Generate the shell script for all the function contains in default.kdl

```bash
eashy
```

3. Source the generated script:

```bash
source ~/.eashy/eashy.sh
```
Add this line to your ~/.bashrc or ~/.zshrc!

(You can change the input/output files, try `eashy --help` for more info)

4. Use your new commands with automatic help:

```bash
venv --help           # Shows main command help
venv init --help      # Shows subcommand help
venv init             # Creates and activates virtual environment
```

## KDL Syntax

### Basic Command Structure

```kdl
my_cmd {
    shell_command arg1 arg2
    another_command "with" "arguments"
}
```

### Command with positional and optional arguments

```kdl
new_sh_file filename shebang="#!/bin/sh" {
    "filename=${filename%.*}.sh"    // Make sure the name ends with .sh (Quotes for escaping '{' and '}' characters)
    echo $shebang > $filename       // Create the file and write the shebang
    chmod +x $filename              // Make the file executable
}
```

### Nested Subcommands with description

```kdl
("Main command description") \
main_command {
    ("Subcommand description") \
    sub_command ("Arg help section")arg {
        echo "This is a subcommand with one arg: $arg"
    }

    ("Another subcommand") \
    another_sub find=("Help for optional args too, default empty")"" {
        ls "-la" | grep "$find"
    }
}
```

See the help section with:
```sh
main_command --help
main_command sub_command -h
...
```

### Command Prefixes

Eashy supports special prefixes for flow control:

- `command_name`  - **Execute All**: Run all commands regardless of success/failure
- `&command_name` - **Until Error**: Stop execution if one command fails
- `|command_name` - **Until Success**: Stop execution if one command succeeds

Example:

```kdl
&stop_on_error {
    echo "This command has a & prefix"
    "false"
    echo "This will not run as the previous command fails"
}

|stop_on_success {
    "false"
    echo "This command has a | prefix"
    echo "This will not run as the previous command succeeds"
}
```

## Generated Output

Eashy generates optimized shell functions with:

- **Automatic help parsing**: Recognizes `-h` and `--help` flags
- **Colorized output**: Beautiful, inspired by `cargo` or `uv` help section
- **Error handling**: Proper error messages for unknown subcommands

## Use Cases

### Development Workflows

Perfect for creating project-specific command shortcuts:

```kdl
("Development commands") \
dev {
    ("Start development server") \
    start {
        npm "run" "dev"
    }

    ("Run tests") \
    test {
        npm "run" "test"
    }

    ("Build for production") \
    build {
        npm "run" "build"
    }
}
```

### Environment Management

Simplify environment setup and management:

```kdl
("Docker operations") \
docker {
    ("Start all services") \
    up {
        docker-compose "up" "-d"
    }

    ("Stop all services") \
    down {
        docker-compose "down"
    }

    ("View logs") \
    logs {
        docker-compose "logs" "-f"
    }
}
```

### Git Workflows

Create custom git command combinations:

```kdl
("Git workflow shortcuts") \
git-flow {
    ("Quick commit and push") \
    qcp {
        git "add" "."
        git "commit" "-m" "Quick commit"
        git "push"
    }

    ("Create and switch to new branch") \
    new-branch {
        git "checkout" "-b"
        git "push" "-u" "origin"
    }
}
```

## Why Eashy?

- **Declarative**: Define what you want, not how to implement it
- **Maintainable**: Easy to modify and extend command definitions
- **Consistent**: Standardized help format across all commands
- **Efficient**: Generates optimized shell code
- **Portable**: Works with any POSIX-compliant shell

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the Apache-2.0 License - see the [LICENSE](LICENSE) file for details.

## Links

- [Repository](https://github.com/jilchab/eashy)
- [KDL Language](https://kdl.dev/) - Learn more about the KDL format
