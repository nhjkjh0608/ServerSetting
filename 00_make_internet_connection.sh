#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

# IPv4 Preference

echo "# IPv4 preferred over IPv6 (IPv4-mapped precedence)"
if grep -qE '^[[:space:]]*precedence[[:space:]]+::ffff:0:0/96[[:space:]]+' /etc/gai.conf; then
  echo "[INFO] Found active precedence line. Updating weight to 100..."
  sed -i -E 's/^([[:space:]]*precedence[[:space:]]+::ffff:0:0\/96[[:space:]]+)[0-9]+/\1100/' /etc/gai.conf
else
  echo "[INFO] No active precedence line found. Appending new line..."
  echo 'precedence ::ffff:0:0/96  100' | sudo tee -a /etc/gai.conf >/dev/null
fi

echo "[INFO] Current active precedence lines:"
grep -nE "^[[:space:]]*precedence[[:space:]]+::ffff:0:0/96[[:space:]]+" /etc/gai.conf

# Make internet connection

ADDR="${1:-}"
if [[ -z "$ADDR" ]]; then
  read -p "Enter IP address: " ADDR
fi

DEFAULT_OUT="/etc/netplan/99-internet-connection.yaml"
python3 _10_make_netplan_yaml.py --addr "$ADDR" --out "$DEFAULT_OUT"
chmod 0600 "$DEFAULT_OUT"

echo "[INFO] netplan generate..."
netplan generate
echo "[INFO] When prompted by netplan, confirm to keep the config."
netplan try
echo "[INFO] netplan try confirmed. Applying permanently..."
netplan apply

echo "[INFO] Done. Current network summary:"
ip -br addr || true
ip route || true
