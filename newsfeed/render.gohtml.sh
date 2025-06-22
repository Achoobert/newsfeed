#!/bin/bash
set -e

cd "$(dirname "$0")"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed"
    echo ""
    echo "Install jq on your system:"
    echo "  Amazon Linux/RHEL/CentOS: sudo yum install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS: brew install jq"
    echo ""
    echo "Or download from: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Read about.md content
ABOUT_NAME=""
ABOUT_LINK=""
ABOUT_QUOTE=""
SITE_URL=""

if [ -f "../template/about.md" ]; then
  ABOUT_NAME=$(grep "name" "../template/about.md" | sed 's/.*name[[:space:]]*:[[:space:]]*//')
  ABOUT_LINK=$(grep "link" "../template/about.md" | sed 's/.*link[[:space:]]*:[[:space:]]*//')
  ABOUT_QUOTE=$(grep "quote" "../template/about.md" | sed 's/.*quote[[:space:]]*:[[:space:]]*//')
  SITE_URL=$(grep "site" "../template/about.md" | sed 's/.*site[[:space:]]*:[[:space:]]*//')
fi

# Default to localhost if no site URL found
if [ -z "$SITE_URL" ]; then
  SITE_URL="http://localhost:8071"
fi

# Ensure src directory exists
mkdir -p ../src

# Ensure links.json exists
[ -f links.json ] || echo '[]' > links.json

# Generate link entries HTML
LINK_ENTRIES=""
jq -c '.[]' links.json | while read -r entry; do
  TITLE=$(echo "$entry" | jq -r '.title // "(no title)"')
  URL=$(echo "$entry" | jq -r '.url')
  DESC=$(echo "$entry" | jq -r '.description')
  DATE=$(echo "$entry" | jq -r '.date')
  THUMB=$(echo "$entry" | jq -r '.thumbnail // empty')
  SITE_NAME=$(echo "$entry" | jq -r '.site_name // empty')
  FAVICON=$(echo "$entry" | jq -r '.favicon // empty')
  META_DESC=$(echo "$entry" | jq -r '.description // empty')
  
  # Use metadata description if available, otherwise use user description
  DISPLAY_DESC="$DESC"
  if [ -n "$META_DESC" ] && [ "$META_DESC" != "null" ]; then
    DISPLAY_DESC="$META_DESC"
  fi
  
  ENTRY_HTML="      <article class=\"entry\">"
  
  # Add thumbnail if available
  if [ -n "$THUMB" ] && [ "$THUMB" != "null" ]; then
    ENTRY_HTML="$ENTRY_HTML
        <a href=\"$URL\" target=\"_blank\" rel=\"noopener noreferrer\"><img class=\"thumb\" src=\"$THUMB\" alt=\"Thumbnail for $(echo "$TITLE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')\"></a>"
  fi
  
  # Add favicon and site name if available
  if [ -n "$FAVICON" ] && [ "$FAVICON" != "null" ]; then
    ENTRY_HTML="$ENTRY_HTML
        <div class=\"site-info\">
          <img class=\"favicon\" src=\"$FAVICON\" alt=\"\" width=\"16\" height=\"16\">"
    if [ -n "$SITE_NAME" ] && [ "$SITE_NAME" != "null" ]; then
      ENTRY_HTML="$ENTRY_HTML <span class=\"site-name\">$SITE_NAME</span>"
    fi
    ENTRY_HTML="$ENTRY_HTML
        </div>"
  fi
  
  ENTRY_HTML="$ENTRY_HTML
        <h2><a href=\"$URL\" target=\"_blank\" rel=\"noopener noreferrer\">$(echo "$TITLE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</a></h2>"
  
  # Add description if available
  if [ -n "$DISPLAY_DESC" ] && [ "$DISPLAY_DESC" != "null" ]; then
    ENTRY_HTML="$ENTRY_HTML
        <p class=\"desc\">$(echo "$DISPLAY_DESC" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</p>"
  fi
  
  ENTRY_HTML="$ENTRY_HTML
        <time class=\"date\" datetime=\"$(echo "$DATE" | sed 's/, 2025 at /T/' | sed 's/ AM/ UTC/' | sed 's/ PM/ UTC/')\">$DATE</time>
      </article>"
  
  echo "$ENTRY_HTML"
done > /tmp/link_entries.tmp

# Read the template and replace placeholders
if [ -f "../template/index.html.template" ]; then
  cat "../template/index.html.template" | \
    sed "s/{{ABOUT_NAME}}/$ABOUT_NAME/g" | \
    sed "s|{{ABOUT_LINK}}|$ABOUT_LINK|g" | \
    sed "s/{{ABOUT_QUOTE}}/$ABOUT_QUOTE/g" | \
    sed "/{{LINK_ENTRIES}}/r /tmp/link_entries.tmp" | \
    sed "/{{LINK_ENTRIES}}/d" > ../src/index.html
else
  echo "Error: Template file not found at ../template/index.html.template"
  exit 1
fi

# Clean up temp file
rm -f /tmp/link_entries.tmp

# Generate sitemap
./generate-sitemap.sh

# Add robots.txt to src directory
cat > ../src/robots.txt <<EOF
User-agent: *
Allow: /

# Sitemap
Sitemap: $SITE_URL/sitemap.xml

# Crawl-delay for polite crawling
Crawl-delay: 1
EOF