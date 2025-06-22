#!/bin/bash
set -e

cd "$(dirname "$0")"

# Read remote URL from about.md
REMOTE_URL=""
if [ -f "../template/about.md" ]; then
  REMOTE_URL=$(grep "remote" "../template/about.md" | sed 's/.*remote[[:space:]]*//')
fi

if [ -z "$REMOTE_URL" ]; then
  echo "No remote URL found in about.md"
  exit 1
fi

echo "Checking for updates from: $REMOTE_URL"

# Check if we're in a git repository
if [ ! -d "../.git" ]; then
  echo "Not in a git repository. Initializing..."
  cd ..
  git init
  git remote add origin "$REMOTE_URL"
  git fetch origin
  git checkout -b main origin/main 2>/dev/null || git checkout -b main
  cd sync
fi

# Fetch latest changes
cd ..
git fetch origin

# Check if local is behind remote
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
  echo "Updates found! Pulling latest changes..."
  git pull origin main
  
  # Regenerate HTML after update
  cd newsfeed
  ./render.gohtml.sh
  echo "✅ Updated and regenerated HTML"
else
  echo "✅ Already up to date"
fi 