#!/bin/bash
# Paste into Hostinger VPS Console (or any shell ON 187.77.162.79)
# Deploys QT-ERP-2026-036.rootk-eg.com from GitHub
set -euo pipefail

APP_DIR=/var/www/QT-ERP-2026-036
DOMAIN=QT-ERP-2026-036.rootk-eg.com
REPO=https://github.com/Salem-Team/QT-ERP-2026-036.git

mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [[ -d .git ]]; then
  git fetch origin main
  git checkout main
  git reset --hard origin/main
else
  # Private repo: use a token if needed
  # GIT_TOKEN=ghp_xxx git clone https://x-access-token:${GIT_TOKEN}@github.com/Salem-Team/QT-ERP-2026-036.git .
  git clone --branch main "$REPO" .
fi

chmod +x deploy/vps-nginx-sync.sh
bash deploy/vps-nginx-sync.sh

echo ">>> Test"
curl -sI -H "Host: ${DOMAIN}" http://127.0.0.1/ | head -5
echo ">>> Live: https://${DOMAIN}/"
