#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

# For safety
set +u
source /usr/share/lmod/lmod/init/bash
set -u
module use /usr/share/modulefiles/Core
module load anaconda3

conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r


# TODO: UV + pip 로 실햄 ㅅ크립트 변경
conda create -q -p /opt/anaconda3/envs/torch2.10-cuda13.0 python=3.10 pytorch torchvision torchaudio pytorch-cuda=12.1 uv \
  -c pytorch -c nvidia -c conda-forge -y


conda clean --all -y