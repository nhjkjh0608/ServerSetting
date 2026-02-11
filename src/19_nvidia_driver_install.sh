#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "[INFO] $*"; }

# --- 1) get version number ---
ver="${1:-}"
if [[ -z "${ver}" ]]; then
  read -r -p "Enter NVIDIA driver version number (e.g., 580): " ver
fi

[[ "${ver}" =~ ^[0-9]+$ ]] || die "Version must be digits only (e.g., 580). Got: '${ver}'"

pkg="nvidia-driver-${ver}-server-open"

# --- 2) check availability in ubuntu-drivers output ---
drivers_out="$(ubuntu-drivers devices 2>/dev/null || true)"

if ! grep -qE "driver\s*:\s*${pkg}\b" <<<"${drivers_out}"; then
  echo "Available NVIDIA server-open drivers found:"
  echo "${drivers_out}" | grep -E "driver\s*:\s*nvidia-driver-[0-9]+-server-open\b" || true
  die "Requested package '${pkg}' is not listed by 'ubuntu-drivers devices' on this system."
fi

info "Package '${pkg}' is listed as available by ubuntu-drivers."

# --- 3) check if installed ---
if dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
  info "'${pkg}' is already installed. Nothing to do."
  exit 0
fi

# Verify that apt can see the package (extra safety)
if ! apt-cache show "${pkg}" >/dev/null 2>&1; then
  die "APT cannot find package '${pkg}'. Check your apt sources (e.g., non-free/restricted enabled) and run 'sudo apt update'."
fi

# --- 4) install ---
info "Installing '${pkg}'..."

sudo apt-get install -y "${pkg}"

info "Done. You may need to reboot for the driver to take effect."
info "Check with: nvidia-smi"
