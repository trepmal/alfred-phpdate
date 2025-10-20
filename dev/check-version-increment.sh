#!/bin/bash
# check-version-increment.sh
# Fails if the version in info.plist is not greater than the latest git tag (v*)

set -e

# Optionally fetch tags if running in CI
git fetch --tags > /dev/null 2>&1 || true

# Extract current version from info.plist
current_version=$(grep -A1 '<key>version</key>' info.plist | tail -n1 | sed -e 's/<[^>]*>//g' | tr -d '[:space:]')

# Get latest tag matching v*
latest_tag=$(git tag --list 'v*' --sort=-v:refname | head -n1)
latest_version=$(echo "$latest_tag" | sed 's/^v//')

if [ -z "$latest_version" ]; then
  echo "No previous release tag found. Proceeding."
  exit 0
fi
if [ "$current_version" = "$latest_version" ]; then
  echo "Version has not been incremented. Current version ($current_version) matches latest release ($latest_version)."
  exit 1
fi
if [ "$(printf '%s\n%s' "$latest_version" "$current_version" | sort -V | tail -n1)" != "$current_version" ]; then
  echo "Current version ($current_version) is not greater than latest release ($latest_version)."
  exit 1
fi
echo "Version increment check passed."
