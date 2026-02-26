#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: Please run as root (e.g., sudo $0)" >&2
  exit 1
fi

apt update
apt install -y lmod


curl -L -O https://repo.anaconda.com/archive/Anaconda3-2025.12-2-Linux-x86_64.sh
bash Anaconda3-2025.12-2-Linux-x86_64.sh -b -p /opt/anaconda3
chmod -R 755 /opt/anaconda3



if ! grep -Eq '^[[:space:]]*/usr/share/modulefiles/Core[[:space:]]*$' "/etc/lmod/modulespath"; then
  printf '\n/usr/share/modulefiles/Core\n' >> "/etc/lmod/modulespath"
fi

mkdir -p /usr/share/modulefiles/Core/
cat > /usr/share/modulefiles/Core/anaconda3.lua <<EOF
help([[
Description:
    Anaconda3 (2025.12)
    Standard Python Distribution.
]])

whatis("Name: Anaconda3")
whatis("Version: 2025.12")
whatis("Category: tools")

local base = "/opt/anaconda3"

prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("MANPATH", pathJoin(base, "share/man"))

if (mode() == "load") then
    local conda_sh = pathJoin(base, "etc/profile.d/conda.sh")
    if (isFile(conda_sh)) then
        source_sh("bash", conda_sh)
    end
end
EOF
chmod 644 /usr/share/modulefiles/Core/anaconda3.lua

cat > /etc/profile.d/z01_anaconda_autoload.sh << EOF
if [ -n "\$LMOD_CMD" ]; then
    module -q load anaconda3
fi
EOF
chmod 644 /etc/profile.d/z01_anaconda_autoload.sh


rm Anaconda3-2025.12-2-Linux-x86_64.sh