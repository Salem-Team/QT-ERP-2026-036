#!/bin/bash
# Run on VPS after files are synced to /var/www/QT-ERP-2026-036
set -euo pipefail

APP_DIR="${APP_DIR:-/var/www/QT-ERP-2026-036}"
DOMAIN="${DOMAIN:-QT-ERP-2026-036.rootk-eg.com}"
SITE="/etc/nginx/sites-available/${DOMAIN}"
HTTP_CONF="$APP_DIR/deploy/nginx-QT-ERP-2026-036.rootk-eg.com.conf"
SSL_CONF="$APP_DIR/deploy/nginx-QT-ERP-2026-036.ssl.conf"

echo ">>> Deploy nginx for ${DOMAIN}"

if [[ -f /etc/letsencrypt/live/rootk-eg.com/fullchain.pem ]]; then
  echo ">>> Using wildcard SSL (rootk-eg.com)"
  cp "$SSL_CONF" "$SITE"
elif [[ -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ]]; then
  echo ">>> Using domain SSL (${DOMAIN})"
  sed "s|/etc/letsencrypt/live/rootk-eg.com|/etc/letsencrypt/live/${DOMAIN}|g" "$SSL_CONF" > "$SITE"
else
  echo ">>> No SSL cert found — HTTP only"
  cp "$HTTP_CONF" "$SITE"
fi

ln -sfn "$SITE" "/etc/nginx/sites-enabled/${DOMAIN}"
nginx -t
systemctl reload nginx

echo ">>> Smoke"
curl -fsS -o /dev/null -w "HTTP %{http_code}\n" -H "Host: ${DOMAIN}" "http://127.0.0.1/" || true
if [[ -f /etc/letsencrypt/live/rootk-eg.com/fullchain.pem ]] || [[ -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ]]; then
  curl -kfsS -o /dev/null -w "HTTPS %{http_code}\n" "https://${DOMAIN}/" || true
fi
echo ">>> Live: https://${DOMAIN}/"
