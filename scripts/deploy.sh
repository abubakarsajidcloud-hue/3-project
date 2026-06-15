#!/bin/bash
# ─────────────────────────────────────────────
# deploy.sh – Pull latest code and reload Nginx
# Usage: ./scripts/deploy.sh [branch]
# ─────────────────────────────────────────────
set -euo pipefail

BRANCH="${1:-main}"
APP_DIR="/var/www/html"
REPO_URL="${REPO_URL:-}"  # set this env var or hard-code your repo

echo "[$(date)] Starting deployment from branch: $BRANCH"

# Pull from repo if URL is set
if [ -n "$REPO_URL" ]; then
  if [ -d "$APP_DIR/.git" ]; then
    echo "Pulling latest changes..."
    git -C "$APP_DIR" fetch origin
    git -C "$APP_DIR" checkout "$BRANCH"
    git -C "$APP_DIR" pull origin "$BRANCH"
  else
    echo "Cloning repository..."
    git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
  fi
fi

# Reload Nginx (zero-downtime)
echo "Reloading Nginx..."
nginx -t
systemctl reload nginx

echo "[$(date)] Deployment complete."
