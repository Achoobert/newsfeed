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

if [ -f "../template/about.md" ]; then
  ABOUT_NAME=$(grep "name" "../template/about.md" | sed 's/.*name[[:space:]]*:[[:space:]]*//')
  ABOUT_LINK=$(grep "link" "../template/about.md" | sed 's/.*link[[:space:]]*:[[:space:]]*//')
  ABOUT_QUOTE=$(grep "quote" "../template/about.md" | sed 's/.*quote[[:space:]]*:[[:space:]]*//')
fi

# Ensure src directory exists
mkdir -p ../src

cat > ../src/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="A curated collection of interesting links and resources">
  <meta name="author" content="$ABOUT_NAME">
  <meta name="robots" content="index, follow">
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'none';">
  <title>Links - $ABOUT_NAME</title>
  
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="Links - $ABOUT_NAME">
  <meta property="og:description" content="A curated collection of interesting links and resources">
  
  <!-- Twitter -->
  <meta property="twitter:card" content="summary">
  <meta property="twitter:title" content="Links - $ABOUT_NAME">
  <meta property="twitter:description" content="A curated collection of interesting links and resources">
  
  <style>
    /* Reset and base styles */
    * {
      box-sizing: border-box;
    }
    
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      max-width: 1200px; 
      margin: 2em auto; 
      display: flex;
      gap: 2em;
      line-height: 1.6;
      color: #333;
      background-color: #fff;
    }
    
    /* Skip to main content link for screen readers */
    .skip-link {
      position: absolute;
      top: -40px;
      left: 6px;
      background: #000;
      color: #fff;
      padding: 8px;
      text-decoration: none;
      z-index: 1000;
    }
    
    .skip-link:focus {
      top: 6px;
    }
    
    /* About section */
    .about {
      flex: 0 0 250px;
      background: #f5f5f5;
      padding: 1.5em;
      border-radius: 8px;
      height: fit-content;
      position: sticky;
      top: 2em;
    }
    
    .about h2 {
      margin-top: 0;
      color: #333;
      font-size: 1.5em;
    }
    
    .about p {
      margin: 0.5em 0;
      line-height: 1.4;
    }
    
    .about .quote {
      font-style: italic;
      color: #666;
      border-left: 3px solid #ddd;
      padding-left: 1em;
      margin-top: 1em;
    }
    
    /* Main content */
    .content {
      flex: 1;
      max-width: 600px;
    }
    
    .content h1 {
      margin-top: 0;
      font-size: 2em;
      color: #333;
    }
    
    /* Link entries */
    .entry { 
      margin-bottom: 2em; 
      border-bottom: 1px solid #eee; 
      padding-bottom: 1em; 
    }
    
    .entry:last-child {
      border-bottom: none;
    }
    
    .thumb { 
      max-width: 100%; 
      height: auto; 
      display: block; 
      margin-bottom: 0.5em;
      border-radius: 4px;
    }
    
    .desc { 
      color: #444; 
      margin: 0.5em 0; 
    }
    
    .date { 
      color: #888; 
      font-size: 0.9em; 
    }
    
    /* Links */
    a { 
      text-decoration: none; 
      color: #1a0dab; 
      transition: color 0.2s ease;
    }
    
    a:hover {
      text-decoration: underline;
      color: #0d47a1;
    }
    
    a:focus {
      outline: 2px solid #1a0dab;
      outline-offset: 2px;
      border-radius: 2px;
    }
    
    /* Focus indicators for all interactive elements */
    button:focus,
    input:focus,
    textarea:focus,
    select:focus {
      outline: 2px solid #1a0dab;
      outline-offset: 2px;
    }
    
    /* Responsive design */
    @media (max-width: 768px) {
      body {
        flex-direction: column;
        margin: 1em;
        gap: 1em;
      }
      
      .about {
        position: static;
        flex: none;
      }
      
      .content {
        max-width: none;
      }
    }
    
    /* High contrast mode support */
    @media (prefers-contrast: high) {
      body {
        color: #000;
        background-color: #fff;
      }
      
      .about {
        background: #e0e0e0;
        border: 2px solid #000;
      }
      
      a {
        color: #0000ee;
      }
      
      a:focus {
        outline: 3px solid #000;
      }
    }
    
    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
      * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }
    
    /* Print styles */
    @media print {
      body {
        max-width: none;
        margin: 0;
        display: block;
      }
      
      .about {
        position: static;
        background: none;
        border: 1px solid #000;
      }
      
      a {
        color: #000;
        text-decoration: underline;
      }
      
      a[href^="http"]:after {
        content: " (" attr(href) ")";
        font-size: 0.8em;
        color: #666;
      }
    }
  </style>
</head>
<body>
  <!-- Skip to main content link for accessibility -->
  <a href="#main-content" class="skip-link">Skip to main content</a>
  
  <aside class="about" role="complementary" aria-labelledby="about-heading">
    <h2 id="about-heading">About</h2>
    <p><strong>Name:</strong> $ABOUT_NAME</p>
    <p><strong>Profile:</strong> <a href="$ABOUT_LINK" target="_blank" rel="noopener noreferrer">StartPlaying.games</a></p>
    <blockquote class="quote" cite="$ABOUT_LINK">
      "$ABOUT_QUOTE"
    </blockquote>
  </aside>
  
  <main id="main-content" class="content" role="main">
    <h1>Links</h1>
    
    <section aria-label="Link entries">
EOF

jq -c '.[]' links.json | while read -r entry; do
  TITLE=$(echo "$entry" | jq -r '.title // "(no title)"')
  URL=$(echo "$entry" | jq -r '.url')
  DESC=$(echo "$entry" | jq -r '.description')
  DATE=$(echo "$entry" | jq -r '.date')
  THUMB=$(echo "$entry" | jq -r '.thumbnail // empty')
  echo "      <article class=\"entry\">" >> ../src/index.html
  if [ -n "$THUMB" ] && [ "$THUMB" != "null" ]; then
    echo "        <a href=\"$URL\" target=\"_blank\" rel=\"noopener noreferrer\"><img class=\"thumb\" src=\"$THUMB\" alt=\"Thumbnail for $(echo "$TITLE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')\"></a>" >> ../src/index.html
  fi
  echo "        <h2><a href=\"$URL\" target=\"_blank\" rel=\"noopener noreferrer\">$(echo "$TITLE" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</a></h2>" >> ../src/index.html
  echo "        <p class=\"desc\">$(echo "$DESC" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')</p>" >> ../src/index.html
  echo "        <time class=\"date\" datetime=\"$(echo "$DATE" | sed 's/, 2025 at /T/' | sed 's/ AM/ UTC/' | sed 's/ PM/ UTC/')\">$DATE</time>" >> ../src/index.html
  echo "      </article>" >> ../src/index.html
  echo >> ../src/index.html
  done

echo "    </section>" >> ../src/index.html
echo "  </main>" >> ../src/index.html

# Add robots.txt to src directory
cat > ../src/robots.txt <<EOF
User-agent: *
Allow: /

# Sitemap (if you add one later)
# Sitemap: https://yourdomain.com/sitemap.xml

# Crawl-delay for polite crawling
Crawl-delay: 1
EOF

echo "</body></html>" >> ../src/index.html