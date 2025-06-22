#!/bin/bash

# Script to fix merge conflicts on remote server
# This removes tracked generated files and regenerates them

set -e

echo "🔧 Fixing merge conflicts on remote server..."

# Check if we're in the right directory
if [ ! -f "sync/update.sh" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Remove tracked generated files from git
echo "🗑️  Removing tracked generated files..."
git rm --cached src/index.html 2>/dev/null || true
git rm --cached src/sitemap.xml 2>/dev/null || true
git rm --cached src/robots.txt 2>/dev/null || true

# Reset any staged changes
echo "🔄 Resetting staged changes..."
git reset HEAD

# Clean up any merge conflicts
echo "🧹 Cleaning up merge conflicts..."
git checkout --theirs src/index.html 2>/dev/null || true
git checkout --theirs src/sitemap.xml 2>/dev/null || true
git checkout --theirs src/robots.txt 2>/dev/null || true

# Remove the conflicted files
rm -f src/index.html src/sitemap.xml src/robots.txt

# Regenerate the files
echo "🔄 Regenerating files..."
cd newsfeed
./render.gohtml.sh
cd ..

# Add the changes to git
echo "📝 Adding changes to git..."
git add .gitignore
git add sync/update.sh
git add newsfeed/backup-links.sh
git add newsfeed/tests/
git add README.md

# Commit the changes
echo "💾 Committing changes..."
git commit -m "Fix merge conflicts and update generated files structure

- Remove tracked generated files from git
- Update .gitignore to explicitly ignore generated files
- Add backup-links.sh and tests directory
- Update documentation"

echo "✅ Merge conflicts fixed! You can now pull updates safely."
echo "💡 Run './sync/update.sh' to check for future updates." 