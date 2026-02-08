#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/apt/apt.conf.d/50unattended-upgrades"

die(){ echo "ERROR: $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Run as root: sudo $0"
[[ -f "$CONF" ]] || die "Not found: $CONF"

tmp="$(mktemp)"; trap 'rm -f "$tmp"' EXIT

awk '
  BEGIN {
    inblk=0; seen=0;
    n1=0; n2=0; n3=0; n4=0;
  }

  /^[[:space:]]*Unattended-Upgrade::Package-Blacklist[[:space:]]*\{/ { inblk=1; seen=1 }

  inblk {
    if ($0 ~ /"\^nvidia-";/)                 n1=1
    if ($0 ~ /"\^libnvidia-";/)              n2=1
    if ($0 ~ /"\^linux-modules-nvidia-";/)   n3=1
    if ($0 ~ /"\^linux-objects-nvidia-";/)   n4=1
  }

  # Close of blacklist block: add only missing lines right before };
  inblk && $0 ~ /^[[:space:]]*\};/ {
    if (!n1) print "    \"^nvidia-\";"
    if (!n2) print "    \"^libnvidia-\";"
    if (!n3) print "    \"^linux-modules-nvidia-\";"
    if (!n4) print "    \"^linux-objects-nvidia-\";"
    inblk=0
  }

  { print }

  END {
    if (!seen) {
      print ""
      print "Unattended-Upgrade::Package-Blacklist {"
      print "    \"^nvidia-\";"
      print "    \"^libnvidia-\";"
      print "    \"^linux-modules-nvidia-\";"
      print "    \"^linux-objects-nvidia-\";"
      print "};"
    }
  }
' "$CONF" > "$tmp"

test -s "$tmp"
cp -a "$tmp" "$CONF"
echo "Updated: $CONF"
