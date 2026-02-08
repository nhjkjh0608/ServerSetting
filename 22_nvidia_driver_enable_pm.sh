#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi


cat > /etc/systemd/system/nvidia-pm.service <<'EOF'
[Unit]
Description=Enable NVIDIA Persistence Mode (-pm 1)
After=nvidia-persistenced.service
Wants=nvidia-persistenced.service

[Service]
Type=simple
ExecStartPre=/bin/sh -c 'for i in $(seq 1 30); do /usr/bin/nvidia-smi -L >/dev/null 2>&1 && exit 0; sleep 1; done; exit 1'
ExecStart=/usr/bin/nvidia-smi -pm 1

TimeoutStartSec=0
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable --now nvidia-pm.service



