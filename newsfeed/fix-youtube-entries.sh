#!/bin/bash

# Script to fix existing YouTube entries with empty titles/thumbnails
# This will regenerate metadata for all YouTube links in links.json

set -e

echo "🔧 Fixing YouTube entries with empty metadata..."

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed"
    exit 1
fi

# Check if links.json exists
if [ ! -f "links.json" ]; then
    echo "Error: links.json not found"
    exit 1
fi

# Create backup
cp links.json links.json.backup.$(date +%Y%m%d_%H%M%S)
echo "📦 Backup created"

# Get all YouTube URLs that need fixing
echo "🔍 Finding YouTube entries with empty titles or thumbnails..."
YOUTUBE_URLS=$(jq -r '.[] | select((.url | contains("youtube.com") or contains("youtu.be")) and (.title == "" or .title == " - YouTube" or .thumbnail == "")) | .url' links.json)

if [ -z "$YOUTUBE_URLS" ]; then
    echo "✅ No YouTube entries need fixing"
    exit 0
fi

echo "📝 Found $(echo "$YOUTUBE_URLS" | wc -l) YouTube entries to fix:"
echo "$YOUTUBE_URLS"

# Process each YouTube URL
echo "$YOUTUBE_URLS" | while read -r youtube_url; do
    if [ -n "$youtube_url" ]; then
        echo "🔄 Processing: $youtube_url"
        
        # Get the entry index
        INDEX=$(jq -r --arg url "$youtube_url" 'map(.url == $url) | index(true)' links.json)
        
        if [ "$INDEX" != "null" ]; then
            # Fetch new metadata
            NEW_META=$(go run fetchmeta.go "$youtube_url")
            
            # Update the entry with new metadata
            jq --argjson index "$INDEX" --argjson new_meta "$NEW_META" \
               '.[$index] = (.[$index] + $new_meta)' links.json > links.json.tmp && mv links.json.tmp links.json
            
            echo "✅ Updated entry $INDEX"
        fi
    fi
done

# Regenerate HTML
echo "🔄 Regenerating HTML..."
./render.gohtml.sh

echo "✅ YouTube entries fixed! Check the updated site." 