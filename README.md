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
- **Data backup protection during updates**

## Setup
```bash
# Make scripts executable
chmod +x add.sh ./newsfeed/render.gohtml.sh ./newsfeed/generate-sitemap.sh
chmod +x sync/update.sh sync/setup-cron.sh

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
- `fetchmeta.go` - Fetch metadata
- `render.gohtml.sh` - Generate HTML
- `generate-sitemap.sh` - Generate sitemap.xml
- `backup-links.sh` - Backup links data
- `tests/fetchmeta_test.go` - Go test suite
- `tests/run-tests.sh` - Test runner script
- `sync/update.sh` - Pull remote updates (with data protection)
- `sync/setup-cron.sh` - Setup automatic updates
- `links.json` - Data storage (git ignored)
- `src/index.html` - Generated site
- `src/sitemap.xml` - Generated sitemap
- `template/about.md` - About content & remote URL
- `template/index.html.template` - HTML template 