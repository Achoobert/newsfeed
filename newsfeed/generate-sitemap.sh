#!/bin/bash
set -e

cd "$(dirname "$0")"

# Read about.md content for site info
SITE_URL=""
if [ -f "../template/about.md" ]; then
  SITE_URL=$(grep "site" "../template/about.md" | sed 's/.*site[[:space:]]*:[[:space:]]*//')
fi

# Default to localhost if no site URL found
if [ -z "$SITE_URL" ]; then
  SITE_URL="http://localhost:8071"
fi

# Ensure src directory exists
mkdir -p ../src

# Get current date in ISO format
CURRENT_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Start sitemap
cat > ../src/sitemap.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>$SITE_URL/</loc>
    <lastmod>$CURRENT_DATE</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>$SITE_URL/about</loc>
    <lastmod>$CURRENT_DATE</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
EOF

# Add individual link pages if they exist
if [ -f links.json ]; then
  jq -c '.[]' links.json | while read -r entry; do
    URL=$(echo "$entry" | jq -r '.url')
    DATE=$(echo "$entry" | jq -r '.date')
    
    # Convert date to ISO format if needed
    if [[ $DATE =~ ^[A-Za-z]+ ]]; then
      # Convert "June 22, 2025 at 08:19 AM" to ISO format
      ISO_DATE=$(date -d "$DATE" -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "$CURRENT_DATE")
    else
      ISO_DATE="$DATE"
    fi
    
    echo "  <url>" >> ../src/sitemap.xml
    echo "    <loc>$URL</loc>" >> ../src/sitemap.xml
    echo "    <lastmod>$ISO_DATE</lastmod>" >> ../src/sitemap.xml
    echo "    <changefreq>monthly</changefreq>" >> ../src/sitemap.xml
    echo "    <priority>0.8</priority>" >> ../src/sitemap.xml
    echo "  </url>" >> ../src/sitemap.xml
  done
fi

# Close sitemap
echo "</urlset>" >> ../src/sitemap.xml

echo "✅ Sitemap generated at ../src/sitemap.xml" 