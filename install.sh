#!/bin/sh
set -eu

# Eashy CLI Installer
# Install it by running:
# curl -fsSL https://github.com/jilchab/eashy/raw/main/install.sh | sh

BINARY_NAME="eashy"
DIR="$HOME/.eashy"
BIN_DIR="$DIR/bin"

detect_platform() {
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$os" in
        Linux) os="unknown-linux-musl" ;;
        Darwin) os="apple-darwin" ;;
        *) echo "Unsupported OS: $os" >&2; exit 1 ;;
    esac

    case "$arch" in
        x86_64) arch="x86_64" ;;
        arm64|aarch64) arch="aarch64" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
    esac

    echo "$arch-$os"
}

get_latest_version() {
    version=$(curl -s "https://api.github.com/repos/jilchab/eashy/releases/latest" \
        | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n 1)

    if [ -z "$version" ]; then
        echo "❌ Failed to fetch latest version from GitHub API" >&2
        exit 1
    fi

    echo "$version"
}

download_and_install() {
    version="$1"
    target="$2"
    tmp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t tmp)"

    archive="$BINARY_NAME-v$version-$target.tar.gz"
    url="https://github.com/jilchab/eashy/releases/download/v$version/$archive"

    if ! curl -Lso  "$tmp_dir/$archive" "$url"; then
        echo "❌ Failed to download $archive" >&2
        rm -rf "$tmp_dir"
        exit 1
    fi

    if ! (cd "$tmp_dir" && tar -xzf "$archive"); then
        echo "❌ Failed to extract $archive" >&2
        rm -rf "$tmp_dir"
        exit 1
    fi

    # Find the binary in the extracted directory
    binary_path="$tmp_dir/$BINARY_NAME-v$version-$target/$BINARY_NAME"
    if [ ! -f "$binary_path" ]; then
        echo "❌ Binary not found at expected path: $binary_path" >&2
        echo "Archive contents:" >&2
        ls -la "$tmp_dir"/ >&2
        rm -rf "$tmp_dir"
        exit 1
    fi

    default_kdl_path="$tmp_dir/$BINARY_NAME-v$version-$target/default.kdl"

    mkdir -p "$BIN_DIR"
    cp "$binary_path" "$BIN_DIR/$BINARY_NAME"

    # Copy default.kdl from the archive if not already present
    if [ -f "$default_kdl_path" ] && [ ! -f "$DIR/default.kdl" ]; then
        cp "$default_kdl_path" "$DIR/default.kdl"
    fi

    chmod +x "$BIN_DIR/$BINARY_NAME"
    rm -rf "$tmp_dir"
}

add_to_path() {
    shell_rc=""
    case "$SHELL" in
        */zsh) shell_rc="$HOME/.zshrc" ;;
        */bash) shell_rc="$HOME/.bashrc" ;;
        *) shell_rc="$HOME/.profile" ;;
    esac

    echo ""
    echo "To use $BINARY_NAME, add it to your PATH:"
    echo "   export PATH=\"$BIN_DIR:\$PATH\""
    echo ""
    echo "Or add this line to your shell configuration ($shell_rc):"
    echo "   echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> $shell_rc"
    echo ""
}

install() {
    echo "Installing $BINARY_NAME..."

    target="$(detect_platform)"
    version="$(get_latest_version)"

    download_and_install "$version" "$target"

    # Run it once
    "$BIN_DIR/$BINARY_NAME" --quiet
    source "$DIR/eashy.sh"

    echo ""
    echo "$BINARY_NAME v$version installed successfully"

    add_to_path
    echo "You can now modify $DIR/default.kdl and run:"
    echo "   eashy"
    echo "Or try running '$BINARY_NAME --help' to get started"
}

install "$@"
