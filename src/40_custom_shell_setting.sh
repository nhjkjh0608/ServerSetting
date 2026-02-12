#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run this script as root or with sudo." >&2
  exit 1
fi

# Starship
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p ~/.config && touch ~/.config/starship.toml

# fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi

# batcat
sudo apt install -y bat
sudo ln -sf /usr/bin/batcat /usr/local/bin/bat


# bashrc setting + initializing starship rs
if ! grep -Fq "# >>> Helpers start >>>" ~/.bashrc 2>/dev/null; then
cat >> ~/.bashrc << 'EOF'
# >>> Helpers start >>>
addnewuser() {
  local USERNAME="$1"

  if [[ $EUID -ne 0 ]]; then
    echo "This function must be run as root"
    return 1
  fi

  if ! id "$USERNAME" >/dev/null 2>&1; then
    useradd -m "$USERNAME"
  fi

  usermod -aG sshusers "$USERNAME"
  chsh -s /bin/bash "$USERNAME"
  passwd "$USERNAME"
}

cbcopy() {
  local data
  data="$(base64 | tr -d '\r\n')"
  printf '\e]52;c;%s\a' "$data"
}


export FZF_DEFAULT_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {}' --preview-window=right:60%:wrap"

# find-based file picker (ignores permission errors, excludes .git)
_fzf_files() {
  find . -path '*/.git/*' -prune -o -type f -print 2>/dev/null | sed 's|^\./||'
}

# open selected file in $EDITOR (default: vim)
fe() {
  local f
  f="$(_fzf_files | fzf)"
  [[ -n "$f" ]] && ${EDITOR:-vim} "$f"
}

fdc() { cd "$(find . -path '*/.git/*' -prune -o -type d -print 2>/dev/null | sed 's|^\./||' | fzf --preview 'ls -la {} | head -200')" || return; }


umask 027
eval "$(starship init bash)"

# <<< Helpers end <<<
EOF
fi
