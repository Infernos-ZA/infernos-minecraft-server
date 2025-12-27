#!/bin/bash
set -e

echo "Building Docker image..."
docker-compose -f docker-compose-infernos-test.yml build

echo ""
echo "Starting Infernos Minecraft server..."
echo "This will:"
echo "  1. Fetch manifest from https://infernos.co.za/api/modpack-templates/public/manifest"
echo "  2. Install NeoForge"
echo "  3. Download all mods with 'server' tag"
echo ""
echo "Press Ctrl+C to stop, or wait for setup to complete"
echo ""

docker-compose -f docker-compose-infernos-test.yml up

