# Newsfeed

A minimalist link curation tool with static HTML generation.

## Quick Start

```bash
# Install dependencies (if needed)
sudo yum install jq  # Amazon Linux/RHEL/CentOS
# OR: sudo apt-get install jq  # Ubuntu/Debian
# OR: brew install jq  # macOS

# Install yt-dlp for YouTube thumbnails (optional but recommended)
./sync/install-ytdlp.sh

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
- **Dedicated `/about` page** with full site description
- Docker-based serving
- Automatic title/thumbnail fetching
- **YouTube thumbnail support via yt-dlp**
- Smart URL handling (auto-prepends https://, validates URLs)
- Automatic updates from remote repository
- **Automatic sitemap generation**
- **Data backup protection during updates**

## Setup
```bash
# Make scripts executable
chmod +x add.sh ./newsfeed/render.gohtml.sh ./newsfeed/generate-sitemap.sh
chmod +x sync/update.sh sync/setup-cron.sh sync/install-ytdlp.sh

# Install yt-dlp for YouTube thumbnails
./sync/install-ytdlp.sh

# Start server
docker compose up -d
or
docker-compose up -d

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

# Backup your links data
./backup-links.sh [backup-name]
```

**Note**: Descriptions can contain spaces and special characters. The script will properly handle multi-word descriptions.

## YouTube Thumbnails

For YouTube videos, the tool automatically fetches thumbnails using `yt-dlp`:

- **Installation**: Run `./sync/install-ytdlp.sh` on your server
- **Automatic**: Thumbnails are fetched when adding YouTube links
- **Fallback**: If `yt-dlp` is blocked by YouTube's bot detection, the tool uses alternative methods
- **Fix Existing**: Use `./fix-youtube-entries.sh` to fix existing YouTube entries with empty metadata

### YouTube Bot Detection Issues

If you see errors like "Sign in to confirm you're not a bot", the tool will:

1. **Try yt-dlp with different options** (user-agent, no-cert-check)
2. **Fall back to direct thumbnail URLs** (usually works even when yt-dlp fails)
3. **Extract video ID** and generate thumbnail URLs manually

### Fix Existing YouTube Entries

If you have YouTube entries with empty titles/thumbnails:

```bash
cd newsfeed
./fix-youtube-entries.sh
```

This will:
- Find all YouTube entries with missing metadata
- Fetch new metadata using the enhanced methods
- Update `links.json` with the new data
- Regenerate the HTML site

## Testing
```bash
# Run all tests
cd newsfeed/tests
./run-tests.sh

# Or run Go tests directly
cd newsfeed/tests
go test -v
```

## Data Protection

The `links.json` file contains your curated links and is automatically protected during updates:

- **Backup during updates**: The update script automatically backs up `links.json` before pulling remote changes
- **Manual backup**: Use `./backup-links.sh [name]` to create timestamped backups
- **Git ignored**: `links.json` is excluded from git tracking to prevent accidental overwrites

If you ever lose data, check for backup files:
```bash
ls -la *.backup*
```

## File Structure
- `add.sh` - Add new links
- `fetchmeta.go` - Fetch metadata (with YouTube support)
- `render.gohtml.sh` - Generate HTML
- `generate-sitemap.sh` - Generate sitemap.xml
- `backup-links.sh` - Backup links data
- `fix-youtube-entries.sh` - Fix YouTube entries with missing metadata
- `tests/fetchmeta_test.go` - Go test suite
- `tests/run-tests.sh` - Test runner script
- `sync/update.sh` - Pull remote updates (with data protection)
- `sync/setup-cron.sh` - Setup automatic updates
- `sync/install-ytdlp.sh` - Install yt-dlp for YouTube thumbnails
- `links.json` - Data storage (git ignored)
- `src/index.html` - Generated main page
- `src/about/index.html` - Generated about page
- `src/sitemap.xml` - Generated sitemap
- `template/about.md` - About content & remote URL
- `template/index.html.template` - Main page HTML template
- `template/about.html.template` - About page HTML template 