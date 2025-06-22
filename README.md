# Newsfeed

A minimalist link curation tool with static HTML generation.

## Quick Start

```bash
# Install dependencies (if needed)
sudo yum install jq  # Amazon Linux/RHEL/CentOS
# OR: sudo apt-get install jq  # Ubuntu/Debian
# OR: brew install jq  # macOS

# Add a link
cd newsfeed
./add.sh http://example.com
# enter description: Your description here

# Serve the site
docker compose up -d
# Visit http://localhost:8071
```

## Features
- CLI tool for adding links with metadata
- Static HTML generation with about section
- Docker-based serving
- Automatic title/thumbnail fetching
- Smart URL handling (auto-prepends https://, validates URLs)
- Automatic updates from remote repository
- **Automatic sitemap generation**

## Setup
```bash
# Make scripts executable
chmod +x add.sh render.gohtml.sh generate-sitemap.sh
chmod +x sync/update.sh sync/setup-cron.sh

# Start server
docker compose up -d

# Optional: Set up automatic updates
./sync/setup-cron.sh
```

## Usage
```bash
# Add a link
./add.sh https://youtube.com/example
# enter description: Example description here

# Check for remote updates
./sync/update.sh

# Generate sitemap manually (optional)
./generate-sitemap.sh
```

## File Structure
- `add.sh` - Add new links
- `fetchmeta.go` - Fetch metadata
- `render.gohtml.sh` - Generate HTML
- `generate-sitemap.sh` - Generate sitemap.xml
- `sync/update.sh` - Pull remote updates
- `sync/setup-cron.sh` - Setup automatic updates
- `links.json` - Data storage
- `src/index.html` - Generated site
- `src/sitemap.xml` - Generated sitemap
- `template/about.md` - About content & remote URL
- `template/index.html.template` - HTML template 