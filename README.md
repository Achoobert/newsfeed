# Newsfeed

A minimalist link curation tool with static HTML generation.

## Quick Start

```bash
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
- YouTube support via yt-dlp
- Smart URL handling (auto-prepends https://, validates URLs)
- Automatic updates from remote repository

## Setup
```bash
# Make scripts executable
chmod +x add.sh render.gohtml.sh
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
```

## File Structure
- `add.sh` - Add new links
- `fetchmeta.go` - Fetch metadata
- `render.gohtml.sh` - Generate HTML
- `sync/update.sh` - Pull remote updates
- `sync/setup-cron.sh` - Setup automatic updates
- `links.json` - Data storage
- `src/index.html` - Generated site
- `template/about.md` - About content & remote URL 