#!/usr/bin/env bash
set -euo pipefail

# Fetches the latest kimi-cli version from PyPI and updates the Homebrew formula

FORMULA="Formula/kimi-cli.rb"
PYPI_URL="https://pypi.org/pypi/kimi-cli/json"

echo "Fetching latest kimi-cli version from PyPI..."
JSON=$(curl -fsSL "$PYPI_URL")

VERSION=$(echo "$JSON" | python3 -c "import sys, json; print(json.load(sys.stdin)['info']['version'])")
echo "Latest version: $VERSION"

CURRENT_VERSION=$(grep -oP 'kimi-cli==\K[0-9.]+' "$FORMULA")
echo "Current version: $CURRENT_VERSION"

if [ "$VERSION" = "$CURRENT_VERSION" ]; then
  echo "Already up to date."
  exit 0
fi

echo "Updating formula to $VERSION..."

# Get the source tarball URL and SHA256
TARBALL_URL=$(echo "$JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for url_info in data['urls']:
    if url_info['packagetype'] == 'sdist':
        print(url_info['url'])
        break
")

SHA256=$(echo "$JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for url_info in data['urls']:
    if url_info['packagetype'] == 'sdist':
        print(url_info['digests']['sha256'])
        break
")

echo "New tarball URL: $TARBALL_URL"
echo "New SHA256: $SHA256"

# Update the formula
sed -i.bak -E "s|url \"https://files.pythonhosted.org/.*\"|url \"$TARBALL_URL\"|" "$FORMULA"
sed -i.bak -E "s|sha256 \"[a-f0-9]+\"|sha256 \"$SHA256\"|" "$FORMULA"
sed -i.bak -E "s|kimi-cli==[0-9.]+|kimi-cli==$VERSION|" "$FORMULA"
rm -f "${FORMULA}.bak"

echo "Formula updated to version $VERSION"
echo ""
echo "Review changes:"
git diff "$FORMULA"
