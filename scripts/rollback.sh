#!/bin/bash
# ─────────────────────────────────────────────
# rollback.sh – Restore a backup from S3
# Usage: ./scripts/rollback.sh <s3-bucket-name> <backup-filename>
# ─────────────────────────────────────────────
set -euo pipefail

BUCKET="${1:-}"
BACKUP_KEY="${2:-}"

if [ -z "$BUCKET" ] || [ -z "$BACKUP_KEY" ]; then
  echo "ERROR: Missing arguments."
  echo "Usage: $0 <bucket-name> <backup-filename>"
  echo ""
  echo "Available backups:"
  aws s3 ls "s3://$BUCKET/backups/" 2>/dev/null || echo "(no backups found)"
  exit 1
fi

RESTORE_TMP="/tmp/rollback_restore"
mkdir -p "$RESTORE_TMP"

echo "[$(date)] Downloading backup from s3://$BUCKET/backups/$BACKUP_KEY ..."
aws s3 cp "s3://$BUCKET/backups/$BACKUP_KEY" "$RESTORE_TMP/backup.tar.gz"

echo "[$(date)] Extracting backup..."
tar -xzf "$RESTORE_TMP/backup.tar.gz" -C /

echo "[$(date)] Reloading Nginx..."
nginx -t && systemctl reload nginx

rm -rf "$RESTORE_TMP"
echo "[$(date)] Rollback complete."
