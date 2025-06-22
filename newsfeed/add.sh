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
# Use absolute path to fetchmeta.go
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_JSON=$(cd "$SCRIPT_DIR" && go run fetchmeta.go "$URL")

# Compose new entry JSON
DATE=$(date '+%B %d, %Y at %I:%M %p')
NEW_ENTRY=$(echo "$META_JSON" | jq --arg url "$URL" --arg desc "$DESCRIPTION" --arg date "$DATE" '. + {"url":$url, "description":$desc, "date":$date}')

# Ensure links.json exists
[ -f "$SCRIPT_DIR/links.json" ] || echo '[]' > "$SCRIPT_DIR/links.json"

# Prepend new entry to links.json
TMP=$(mktemp)
jq --argjson new "$NEW_ENTRY" '. |= [ $new ] + .' "$SCRIPT_DIR/links.json" > "$TMP" && mv "$TMP" "$SCRIPT_DIR/links.json"

# Regenerate index.html
cd "$SCRIPT_DIR" && ./render.gohtml.sh

echo "done!" 