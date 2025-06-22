#!/bin/bash

# Backup script for links.json
# Usage: ./backup-links.sh [backup-name]

BACKUP_NAME="${1:-$(date +%Y%m%d_%H%M%S)}"
BACKUP_FILE="links.json.backup.${BACKUP_NAME}"

if [ -f "links.json" ]; then
    cp links.json "$BACKUP_FILE"
    echo "✅ Backed up links.json to $BACKUP_FILE"
    echo "📊 File size: $(wc -c < "$BACKUP_FILE") bytes"
    echo "📅 Backup time: $(date)"
else
    echo "❌ links.json not found"
    exit 1
fi 