#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/src"

SCRIPTS=(
  "20_enable_ubuntu_pro_subscription.sh"
  "21_hostname_change.sh"
  "22_nvidia_driver_enable_pm.sh"
  "23_nvidia_driver_lock.sh"
  "27_change_info_after_login.sh"
  "30_environment_and_module_install.sh"
  "32_conda_env_setting.sh"
)

for script in "${SCRIPTS[@]}"; do
  path="$SRC_DIR/$script"

  if [[ ! -f "$path" ]]; then
    echo "[ERROR] Missing script: $path" >&2
    exit 1
  fi

  echo "[RUN] $script"
  bash "$path"
done

echo "[DONE] 20~32 script execution completed."
