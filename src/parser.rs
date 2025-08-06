use kdl::{KdlDocument, KdlIdentifier, KdlNode};
use std::{str::FromStr, vec};
use crate::command::{Argument, Command, Prefix};

pub fn parse_commands(doc: &KdlDocument) -> Vec<Command> {
    doc.nodes()
        .iter()
        .map(|node| parse_command_node(node, None))
        .collect()
}

pub fn parse_command_node(node: &KdlNode, path: Option<Vec<String>>) -> Command {
    let (prefix, name) = Prefix::extract(node.name().value());
    let path = path.unwrap_or(vec![name.clone()]);
    let description = node.ty().map(|id| id.value().to_string());
    let arguments = parse_arguments(node);
    let mut subcommands = vec![];
    let mut command_body = vec![];

    if let Some(children) = node.children() {
        // Check if this has subcommands or is a leaf command
        let has_nested_subcommands = children.nodes().iter().any(|n| n.children().is_some());

        if has_nested_subcommands {
            // This has subcommands
            for child in children.nodes() {
                let mut child_path = path.clone();
                child_path.push(child.name().value().to_string());
                let subcmd = parse_command_node(child, Some(child_path));
                subcommands.push(subcmd);
            }
        } else {
            command_body = parse_command_body(children);
        }
    }

    Command {
        name,
        prefix,
        description,
        arguments,
        command_body,
        subcommands,
        path,
    }
}

fn parse_arguments(node: &KdlNode) -> Vec<Argument> {
    let mut arguments = Vec::new();

    for entry in node.entries() {
        let (default_value, name) = match entry.name() {
            Some(name) => (Some(entry.value().to_string()), name.value().to_string()),
            None => (None, entry.value().to_string()),
        };

        let (prefix, name) = Prefix::extract(&name);
        let help = entry.ty()
            .unwrap_or(&KdlIdentifier::from_str(&name.to_uppercase()).unwrap())
            .to_string()
            .trim_matches('"')
            .to_string();
        let is_positional = default_value.is_none();

        arguments.push(Argument {
            name,
            prefix,
            help,
            default_value,
            is_positional,
        });
    }

    arguments
}

fn parse_command_body(children: &KdlDocument) -> Vec<String> {
    let mut command_lines = Vec::new();

    for cmd_node in children.nodes() {
        let cmd_name = cmd_node.name().value();
        let mut cmd_parts = vec![cmd_name.to_string()];

        for entry in cmd_node.entries() {
            let part = entry.value().to_string();
            cmd_parts.push(part);
        }

        command_lines.push(cmd_parts.join(" "));
    }

    command_lines
}
