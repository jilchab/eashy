#!/bin/sh
set -eu

# Extract values from Cargo.toml
BINARY_NAME=$(grep '^name = ' Cargo.toml | sed 's/name = "\(.*\)"/\1/')
GITHUB_REPO=$(grep '^repository = ' Cargo.toml | sed 's/repository = "https:\/\/github\.com\/\(.*\)"/\1/')
DIST_DIR="dist"

# Validate extracted values
if [ -z "$BINARY_NAME" ]; then
    echo "❌ Could not extract binary name from Cargo.toml"
    exit 1
fi

if [ -z "$GITHUB_REPO" ]; then
    echo "❌ Could not extract GitHub repository from Cargo.toml"
    echo "Make sure repository field is set to a GitHub URL in Cargo.toml"
    exit 1
fi

echo "📋 Using binary name: $BINARY_NAME"
echo "📋 Using GitHub repo: $GITHUB_REPO"

# POSIX-compatible target list
TARGETS="
    x86_64-unknown-linux-musl
    aarch64-unknown-linux-gnu
    x86_64-apple-darwin
    aarch64-apple-darwin
"

# Check required tools
check_dependencies() {
    for cmd in rustup cross git gh tar zip; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "❌ Required tool '$cmd' is not installed"
            exit 1
        fi
    done

    # Check if gh is authenticated
    if ! gh auth status > /dev/null 2>&1; then
        echo "❌ GitHub CLI is not authenticated. Run 'gh auth login' first."
        exit 1
    fi
}

# Validate version format (basic semver check)
validate_version() {
    if ! echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$'; then
        echo "❌ Invalid version format. Expected: X.Y.Z or X.Y.Z-suffix"
        exit 1
    fi
}

# Check git status
check_git_status() {
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 [DRY RUN] Would check git status..."
        return 0
    fi

    if [ -n "$(git status --porcelain)" ]; then
        echo "❌ Working directory is not clean. Commit or stash changes first."
        exit 1
    fi

    if ! git diff-index --quiet HEAD --; then
        echo "❌ There are uncommitted changes. Commit them first."
        exit 1
    fi
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <version> [--dry-run]"
  echo "Example: $0 1.0.0"
  echo "Example: $0 1.0.0 --dry-run"
  exit 1
fi

VERSION="$1"
DRY_RUN=false

# Check for dry-run flag
if [ $# -eq 2 ]; then
    if [ "$2" = "--dry-run" ]; then
        DRY_RUN=true
        echo "🔍 DRY RUN MODE - No changes will be made"
    else
        echo "❌ Invalid flag: $2"
        echo "Usage: $0 <version> [--dry-run]"
        exit 1
    fi
fi
TAG="v$VERSION"
ARCHIVE_PREFIX="${BINARY_NAME}-${TAG}"

# Run all checks first
echo "🔍 Running pre-release checks..."
check_dependencies
validate_version "$VERSION"
check_git_status

echo "🚀 Starting release for version $VERSION"

# Update Cargo.toml version (POSIX-compatible sed)
echo "📝 Updating Cargo.toml version..."
if [ "$DRY_RUN" = true ]; then
    echo "🔍 [DRY RUN] Would update Cargo.toml version from $(grep '^version = ' Cargo.toml) to version = \"$VERSION\""
else
    cp Cargo.toml Cargo.toml.backup
    if command -v gsed > /dev/null 2>&1; then
        # Use GNU sed if available (macOS with brew install gnu-sed)
        gsed -i "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
    else
        # Fallback for BSD sed (macOS default) and other systems
        sed -i.bak "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
        rm -f Cargo.toml.bak
    fi

    # Verify the version was updated correctly
    if ! grep -q "^version = \"$VERSION\"" Cargo.toml; then
        echo "❌ Failed to update version in Cargo.toml"
        cp Cargo.toml.backup Cargo.toml
        rm -f Cargo.toml.backup
        exit 1
    fi
    rm -f Cargo.toml.backup
fi

# Git commit and tag
if [ "$DRY_RUN" = true ]; then
    echo "🔍 [DRY RUN] Would run:"
    echo "  git add Cargo.toml"
    echo "  git commit -m \"Release ${TAG}\""
    echo "  git tag \"${TAG}\""
    echo "  git push"
    echo "  git push origin \"${TAG}\""
else
    git add Cargo.toml
    git commit -m "Release ${TAG}"
    git tag "${TAG}"
    git push
    git push origin "${TAG}"
fi

# Prepare dist dir
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

build_and_package() {
    target=$1

    echo "🔨 Building target: $target"
    if [ "$DRY_RUN" = true ]; then
        echo "🔍 [DRY RUN] Would run:"
        echo "  rustup target add \"$target\""
        echo "  cross build --release --target \"$target\""
        echo "  Package binary into ${ARCHIVE_PREFIX}-${target}.tar.gz and .zip"
        return 0
    fi

    rustup target add "$target" || true
    cross build --release --target "$target"

    BIN_PATH="target/$target/release/$BINARY_NAME"

    if [ ! -f "$BIN_PATH" ]; then
        echo "❌ Missing binary for $target"
        exit 1
    fi

    # Strip binary if strip is available
    if command -v strip > /dev/null 2>&1; then
        strip "$BIN_PATH" || true
    fi

    PKG_DIR="${DIST_DIR}/${ARCHIVE_PREFIX}-${target}"
    mkdir -p "$PKG_DIR"
    cp "$BIN_PATH" "$PKG_DIR/"

    # Create archives
    echo "📦 Creating archives for $target..."
    if tar -czf "${DIST_DIR}/${ARCHIVE_PREFIX}-${target}.tar.gz" -C "$DIST_DIR" "${ARCHIVE_PREFIX}-${target}"; then
        echo "✅ Created ${ARCHIVE_PREFIX}-${target}.tar.gz"
    else
        echo "❌ Failed to create tar.gz for $target"
        exit 1
    fi

    if (cd "$DIST_DIR" && zip -rq "${ARCHIVE_PREFIX}-${target}.zip" "${ARCHIVE_PREFIX}-${target}"); then
        echo "✅ Created ${ARCHIVE_PREFIX}-${target}.zip"
    else
        echo "❌ Failed to create zip for $target"
        exit 1
    fi

    rm -rf "$PKG_DIR"
    echo "📦 Packaged ${ARCHIVE_PREFIX}-${target} successfully"
}

for t in $TARGETS; do
    build_and_package "$t"
done

echo "🚀 Uploading release assets to GitHub"
if [ "$DRY_RUN" = true ]; then
    echo "🔍 [DRY RUN] Would run:"
    echo "  gh release create \"$TAG\" --title \"$TAG\" --notes \"Release $TAG\""
    for target in $TARGETS; do
        echo "  gh release upload \"$TAG\" \"${DIST_DIR}/${ARCHIVE_PREFIX}-${target}.tar.gz\""
        echo "  gh release upload \"$TAG\" \"${DIST_DIR}/${ARCHIVE_PREFIX}-${target}.zip\""
    done
else
    if gh release create "$TAG" --title "$TAG" --notes "Release $TAG" --draft=false --prerelease=false; then
        echo "✅ Created GitHub release $TAG"
    else
        echo "ℹ️  Release $TAG already exists, continuing with upload..."
    fi

    # Upload all archive files
    upload_count=0
    for file in "$DIST_DIR"/*.tar.gz "$DIST_DIR"/*.zip; do
        if [ -f "$file" ]; then
            echo "Uploading $file..."
            if gh release upload "$TAG" "$file" --clobber; then
                upload_count=$((upload_count + 1))
            else
                echo "❌ Failed to upload $file"
                exit 1
            fi
        fi
    done

    if [ $upload_count -eq 0 ]; then
        echo "❌ No files were uploaded"
        exit 1
    fi

    echo "✅ Uploaded $upload_count files successfully"
fi

if [ "$DRY_RUN" = true ]; then
    echo "✅ Dry run completed! No changes were made."
    echo "💡 Remove --dry-run flag to perform the actual release."
else
    echo "✅ Release $TAG done!"
fi