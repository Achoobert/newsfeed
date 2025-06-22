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
  
  # Backup links.json if it exists
  if [ -f "newsfeed/links.json" ]; then
    echo "Backing up links.json..."
    cp newsfeed/links.json newsfeed/links.json.backup
  fi
  
  # Stash any local changes to prevent conflicts
  git stash push -m "Auto-stash before pull" 2>/dev/null || true
  
  # Pull latest changes
  git pull origin main
  
  # Restore links.json if it was backed up
  if [ -f "newsfeed/links.json.backup" ]; then
    echo "Restoring links.json..."
    mv newsfeed/links.json.backup newsfeed/links.json
  fi
  
  # Regenerate HTML after update
  cd newsfeed
  ./render.gohtml.sh
  echo "✅ Updated and regenerated HTML"
else
  echo "✅ Already up to date"
fi 