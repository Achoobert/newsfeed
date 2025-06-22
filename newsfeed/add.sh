#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <url>"
  exit 1
fi

URL="$1"

# Auto-prepend https:// if no protocol specified
if [[ ! "$URL" =~ ^https?:// ]]; then
  URL="https://$URL"
  echo "Added https:// to URL: $URL"
fi

# Validate URL with curl
echo "Validating URL..."
if ! curl -s --max-time 10 --head "$URL" > /dev/null 2>&1; then
  echo "Error: Could not reach $URL"
  echo "Please check the URL and try again."
  exit 1
fi

echo "URL validated successfully!"
read -p "enter description: " DESCRIPTION

# Call Go program to fetch metadata (title, thumbnail, og data)
META_JSON=$(go run fetchmeta.go "$URL")

# Compose new entry JSON
DATE=$(date '+%B %d, %Y at %I:%M %p')
NEW_ENTRY=$(echo "$META_JSON" | jq --arg url "$URL" --arg desc "$DESCRIPTION" --arg date "$DATE" '. + {"url":$url, "description":$desc, "date":$date}')

# Ensure links.json exists
[ -f links.json ] || echo '[]' > links.json

# Prepend new entry to links.json
TMP=$(mktemp)
jq --argjson new "$NEW_ENTRY" '. |= [ $new ] + .' links.json > "$TMP" && mv "$TMP" links.json

# Regenerate index.html
./render.gohtml.sh

echo "done!" 