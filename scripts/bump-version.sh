#!/bin/bash
# Usage: ./scripts/bump-version.sh 1.1.0
#
# 버전을 Info.plist, homebrew cask에 일괄 반영하고
# git tag를 생성합니다.

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.1.0"
  exit 1
fi

echo "Bumping to v${VERSION}..."

# Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" MacModoro/Info.plist
echo "  Updated Info.plist"

# Homebrew cask
sed -i '' "s/version \".*\"/version \"${VERSION}\"/" homebrew/macmodoro.rb
echo "  Updated homebrew/macmodoro.rb"

# CHANGELOG reminder
echo ""
echo "Don't forget to update CHANGELOG.md!"
echo ""
echo "Then run:"
echo "  git add -A"
echo "  git commit -m \"release: v${VERSION}\""
echo "  git tag v${VERSION}"
echo "  git push origin main --tags"
