#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

do_upgrade() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y && apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
}

ensure_package() {
  local missing=()
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "[INFO] Installing missing packages: ${missing[*]}"
    apt-get install -y "${missing[@]}"
  fi
}


main(){
  do_upgrade
  # set timezone
  timedatectl set-timezone "$(curl -s http://ip-api.com/line/?fields=timezone)"

  ensure_package python3 python3-venv python3-pip netplan.io openssh-server openssh-client unzip
}

main "$@"
