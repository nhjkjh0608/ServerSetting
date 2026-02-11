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

conda create -q -p /opt/anaconda3/envs/python3.13-torch2.10-cuda13.0 python=3.13 uv -c conda-forge -y
conda activate /opt/anaconda3/envs/python3.13-torch2.10-cuda13.0
which uv
uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu130
conda deactivate

# If a user wants to install additional packages, they should clone the base environment first:
# conda create --name myenv --clone /opt/anaconda/envs/python3.13-torch2.10-cuda13.0

conda clean --all -y