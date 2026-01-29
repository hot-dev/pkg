#!/bin/bash
# Tag all packages with their versions using prefixed tags (e.g., anthropic/v0.1.0)
# This enables shallow clones of specific package versions from the monorepo.
#
# Usage:
#   ./hot-pkg-tag.sh          # Create tags (dry-run by default)
#   ./hot-pkg-tag.sh --push   # Create and push tags
#
# Run this from the pkg repo (not the hot repo)

set -e

PUSH=false
if [ "$1" = "--push" ]; then
    PUSH=true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine if we're in the pkg repo or hot repo
if [ -d "$SCRIPT_DIR/../hot/pkg" ]; then
    # Script is in hot repo's scripts/ directory
    PKG_DIR="$SCRIPT_DIR/../hot/pkg"
    REPO_DIR="$SCRIPT_DIR/.."
elif [ -d "./hot/pkg" ]; then
    # Running from a repo root that has hot/pkg (e.g., pkg repo)
    PKG_DIR="./hot/pkg"
    REPO_DIR="."
else
    echo "Error: Cannot find hot/pkg directory"
    echo "Run this script from a repo containing hot/pkg/"
    exit 1
fi

cd "$REPO_DIR"

echo "Creating package version tags..."

TAGS_CREATED=()

for pkg_hot in "$PKG_DIR"/*/pkg.hot; do
    pkg_dir=$(dirname "$pkg_hot")
    pkg=$(basename "$pkg_dir")

    if [ "$pkg" = "hot-std" ]; then
        continue
    fi

    VERSION=$(grep 'version:' "$pkg_hot" | head -1 | sed -E 's/.*"([0-9]+\.[0-9]+\.[0-9]+)".*/\1/')

    if [ -z "$VERSION" ]; then
        echo "  Skipping $pkg (no version found)"
        continue
    fi

    TAG="$pkg/v$VERSION"

    if git rev-parse "$TAG" >/dev/null 2>&1; then
        echo "  $TAG (already exists)"
    else
        echo "  $TAG (new)"
        git tag "$TAG"
        TAGS_CREATED+=("$TAG")
    fi
done

echo ""

if [ ${#TAGS_CREATED[@]} -eq 0 ]; then
    echo "No new tags created."
else
    echo "Created ${#TAGS_CREATED[@]} new tag(s):"
    for tag in "${TAGS_CREATED[@]}"; do
        echo "  $tag"
    done

    if [ "$PUSH" = true ]; then
        echo ""
        echo "Pushing tags..."
        git push --tags
        echo "Done!"
    else
        echo ""
        echo "To push tags, run: git push --tags"
        echo "Or re-run with: $0 --push"
    fi
fi
