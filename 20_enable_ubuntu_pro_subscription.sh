#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi


# enable ubuntu pro subscription
read -r -s -p "Enter your token: " UBUNTU_PRO_TOKEN
pro attach "$UBUNTU_PRO_TOKEN" || true
pro enable esm-apps  || true
pro enable esm-infra || true
pro enable livepatch || true

echo "Ubuntu pro subscription enabled."
pro status