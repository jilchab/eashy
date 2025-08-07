#!/bin/sh
set -eu

# Eashy CLI Installer
# Install it by running:
# curl -fsSL https://github.com/jilchab/eashy/raw/main/install.sh | sh

REPO="jilchab/eashy"
BINARY_NAME="eashy"
INSTALL_DIR="$HOME/.local/bin"

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
  echo "🔍 Fetching latest version..."
  version=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" \
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
  url="https://github.com/$REPO/releases/download/v$version/$archive"

  echo "📦 Downloading $url..."
  if ! curl -L -o "$tmp_dir/$archive" "$url"; then
    echo "❌ Failed to download $archive" >&2
    rm -rf "$tmp_dir"
    exit 1
  fi

  echo "📂 Extracting..."
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

  echo "📁 Creating install directory..."
  mkdir -p "$INSTALL_DIR"

  echo "🚀 Installing to $INSTALL_DIR..."
  chmod +x "$binary_path"
  cp "$binary_path" "$INSTALL_DIR/$BINARY_NAME"

  rm -rf "$tmp_dir"
  echo "✅ Binary installed successfully"
}

check_existing_installation() {
  if command -v "$BINARY_NAME" > /dev/null 2>&1; then
    existing_version=$("$BINARY_NAME" --version 2>/dev/null | sed 's/.* //' || echo "unknown")
    echo "⚠️  $BINARY_NAME is already installed (version: $existing_version)"
    printf "Do you want to continue and overwrite? [y/N]: "
    read -r response
    case "$response" in
      [yY]|[yY][eE][sS]) echo "Proceeding with installation..." ;;
      *) echo "Installation cancelled."; exit 0 ;;
    esac
  fi
}

add_to_path() {
  shell_rc=""
  case "$SHELL" in
    */zsh) shell_rc="$HOME/.zshrc" ;;
    */bash) shell_rc="$HOME/.bashrc" ;;
    */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
    *) shell_rc="$HOME/.profile" ;;
  esac

  if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo "📝 To use $BINARY_NAME, add it to your PATH:"
    echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
    echo ""
    echo "💡 Or add this line to your shell configuration ($shell_rc):"
    echo "   echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> $shell_rc"
    echo ""
  else
    echo "✅ $INSTALL_DIR is already in your PATH"
  fi
}

install() {
  echo "🚀 Installing $BINARY_NAME..."

  check_existing_installation

  target="$(detect_platform)"
  version="$(get_latest_version)"

  echo "📋 Detected version: v$version"
  echo "📋 Detected target: $target"

  download_and_install "$version" "$target"

  add_to_path

  echo "✅ $BINARY_NAME v$version installed successfully!"
  echo ""
  echo "🎉 Run '$BINARY_NAME --help' to get started"
}

install "$@"
