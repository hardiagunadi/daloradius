#!/usr/bin/env bash
set -euo pipefail

WG_DIR="/etc/wireguard"
SERVER_PUB="/var/www/daloradius/var/log/wireguard-server.pub"

if [ "$(id -u)" -ne 0 ]; then
  if [ -r "${WG_DIR}/wg0.pub" ]; then
    mkdir -p "$(dirname "$SERVER_PUB")"
    cp "${WG_DIR}/wg0.pub" "${SERVER_PUB}"
    chmod 644 "${SERVER_PUB}"
    echo "OK: $(cat "$SERVER_PUB")"
    exit 0
  fi
  echo "wg0.pub not readable and no root privileges"
  exit 1
fi

if [ ! -f "${WG_DIR}/wg0.pub" ]; then
  echo "wg0.pub not found"
  exit 1
fi

mkdir -p "$(dirname "$SERVER_PUB")"
cp "${WG_DIR}/wg0.pub" "${SERVER_PUB}"
chmod 644 "${WG_DIR}/wg0.pub" "${SERVER_PUB}"

echo "OK: $(cat "$SERVER_PUB")"
