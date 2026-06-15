#!/bin/bash
# ─────────────────────────────────────────────
# backup.sh – Back up Nginx config and web root to S3
# Usage: ./scripts/backup.sh <s3-bucket-name>
# ─────────────────────────────────────────────
set -euo pipefail

BUCKET="${1:-}"
if [ -z "$BUCKET" ]; then
  echo "ERROR: Please provide an S3 bucket name as argument."
  echo "Usage: $0 <bucket-name>"
  exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="/tmp/backup_$TIMESTAMP.tar.gz"

echo "[$(date)] Creating backup archive..."
tar -czf "$BACKUP_FILE" \
  /etc/nginx \
  /var/www/html \
  /var/log/nginx

echo "[$(date)] Uploading to s3://$BUCKET/backups/$TIMESTAMP.tar.gz ..."
aws s3 cp "$BACKUP_FILE" "s3://$BUCKET/backups/$TIMESTAMP.tar.gz"

rm -f "$BACKUP_FILE"
echo "[$(date)] Backup complete: $TIMESTAMP.tar.gz"
