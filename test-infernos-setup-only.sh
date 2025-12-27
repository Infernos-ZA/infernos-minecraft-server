#!/bin/bash
set -e

echo "Building Docker image..."
docker-compose -f docker-compose-infernos-test.yml build

echo ""
echo "Running Infernos setup only (will exit after setup completes)..."
echo ""

docker-compose -f docker-compose-infernos-test.yml run --rm mc sh -c "
  export SETUP_ONLY=TRUE
  /start
"

echo ""
echo "Setup complete! Checking results..."
echo ""

docker-compose -f docker-compose-infernos-test.yml run --rm mc sh -c "
  echo '=== Checking mods directory ==='
  ls -lh /data/mods/ | head -20 || echo 'No mods directory'
  echo ''
  echo '=== Mod count ==='
  find /data/mods -name '*.jar' 2>/dev/null | wc -l
  echo ''
  echo '=== Version file ==='
  cat /data/.infernos-version 2>/dev/null || echo 'No version file'
  echo ''
  echo '=== NeoForge installation ==='
  ls -lh /data/neoforge-*.jar 2>/dev/null || ls -lh /data/run.sh 2>/dev/null || echo 'NeoForge not found'
"

