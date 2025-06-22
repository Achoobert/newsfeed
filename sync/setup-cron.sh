#!/bin/bash
set -e

cd "$(dirname "$0")"

# Get the absolute path to the update script
SCRIPT_PATH=$(pwd)/update.sh

echo "Setting up automatic updates..."
echo "This will add a cron job to check for updates every hour"

# Create the cron job entry
CRON_JOB="0 * * * * cd $(pwd) && $SCRIPT_PATH >> /tmp/newsfeed-update.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "newsfeed-update"; then
  echo "Cron job already exists. Removing old entry..."
  crontab -l 2>/dev/null | grep -v "newsfeed-update" | crontab -
fi

# Add the new cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo "✅ Cron job added successfully!"
echo "The system will now check for updates every hour"
echo "Logs will be written to /tmp/newsfeed-update.log"
echo ""
echo "To remove the cron job later, run:"
echo "crontab -l | grep -v 'newsfeed-update' | crontab -" 