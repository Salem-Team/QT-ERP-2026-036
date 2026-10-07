#!/bin/bash
# One-shot deploy from a machine that CAN SSH to the VPS (or Hostinger console).
# Usage: bash deploy/local-to-vps.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Live DNS for QT-ERP-2026-036.rootk-eg.com → 62.72.23.5 (sidracrm-vps-prev)
HOST="${DEPLOY_HOST:-sidracrm-vps-prev}"
APP_DIR="${APP_DIR:-/var/www/QT-ERP-2026-036}"
DOMAIN="${DOMAIN:-QT-ERP-2026-036.rootk-eg.com}"

echo ">>> Sync $ROOT -> $HOST:$APP_DIR"
rsync -az --delete \
  --exclude .git \
  --exclude .github \
  --exclude .DS_Store \
  --exclude .vercel \
  "$ROOT/" "$HOST:$APP_DIR/"

echo ">>> Nginx"
ssh "$HOST" "chmod +x $APP_DIR/deploy/vps-nginx-sync.sh && bash $APP_DIR/deploy/vps-nginx-sync.sh"

echo ">>> Live: https://${DOMAIN}/"
