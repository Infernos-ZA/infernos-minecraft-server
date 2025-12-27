#!/bin/bash
set -euo pipefail

# Verify NeoForge is installed
mc-image-helper assert fileExists "/data/neoforge-*.jar" || mc-image-helper assert fileExists "/data/run.sh"

# Verify mods directory exists and has mods
if [ ! -d "/data/mods" ]; then
  echo "ERROR: /data/mods directory does not exist"
  exit 1
fi

mod_count=$(find /data/mods -name "*.jar" | wc -l)
if [ "$mod_count" -eq 0 ]; then
  echo "ERROR: No mods found in /data/mods"
  exit 1
fi

echo "SUCCESS: Found $mod_count mod(s) in /data/mods"

# Verify version file exists
if [ ! -f "/data/.infernos-version" ]; then
  echo "ERROR: /data/.infernos-version file does not exist"
  exit 1
fi

echo "SUCCESS: Infernos version file exists"
cat /data/.infernos-version

