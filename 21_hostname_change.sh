#!/usr/bin/env bash
set -euo pipefail


if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

CURRENT_HOSTNAME=$(hostname)

echo "============================================"
echo " Current Hostname: $CURRENT_HOSTNAME"
echo " (Rule: Use only lowercase a-z, 0-9, and hyphens '-')"
echo "============================================"
echo ""

# 2. Input Loop (Double verification)
while true; do
    read -p "Enter new hostname: " NEW_HOST1

    # Check if empty
    if [ -z "$NEW_HOST1" ]; then
        echo "Hostname cannot be empty."
        echo ""
        continue
    fi

    # Validate syntax (No underscores, special chars, or uppercase)
    if [[ ! "$NEW_HOST1" =~ ^[a-z0-9-]+$ ]]; then
        echo "Error: Hostname can only contain 'lowercase letters', 'numbers', and 'hyphens(-)'."
        echo ""
        continue
    fi

    read -p "Retype new hostname: " NEW_HOST2

    # Check match
    if [ "$NEW_HOST1" == "$NEW_HOST2" ]; then
        break
    else
        echo "Hostnames do not match. Please try again."
        echo ""
    fi
done

hostnamectl set-hostname "$NEW_HOST1"
sed -i "s/\b${CURRENT_HOSTNAME}\b/${NEW_HOST1}/g" /etc/hosts
echo "Please re-login to see the changes"