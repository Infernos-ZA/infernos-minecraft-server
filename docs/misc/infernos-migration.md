# Migrating from Original Minecraft Server to Docker (Infernos)

This guide will help you migrate from running a traditional, manually-setup Minecraft server to using this Docker-based setup specifically configured for the **Infernos** modpack.

## Overview

The Docker-based setup provides several advantages over a traditional server installation:

- **Automated modpack management**: Automatically fetches and updates the Infernos modpack from the official manifest
- **Consistent environment**: Same Java version and dependencies every time
- **Easy updates**: Update the server image and modpack with simple commands
- **Isolated environment**: Server runs in a container, keeping your system clean
- **Simplified backup**: All server data is in one directory
- **Cross-platform**: Works the same on Windows, Linux, and macOS

## Data Safety

!!! important "Your Data is Safe"

    **No data will be deleted** during migration or when using the Infernos deployment. The system is designed to preserve all your existing data:

    - ✅ **World data**: Completely preserved - worlds are never deleted or modified
    - ✅ **Configuration files**: All config files in `/data/config` are preserved
    - ✅ **Player data**: Player inventories, stats, and progress are safe
    - ✅ **Server settings**: `server.properties`, `ops.json`, `whitelist.json`, etc. are preserved
    - ✅ **Existing mods**: Old mods in `/data/mods` are not automatically deleted
    - ✅ **Logs**: Server logs are preserved

    The Infernos deployment script:
    - Only **adds** new mods from the manifest to `/data/mods`
    - Only **updates** mods when the modpack version changes (replaces with new versions)
    - **Never deletes** world data, config files, or player data
    - Uses `ensureRemoveAllModsOff` to **disable** automatic mod removal features

    When migrating, you're **copying** your data to a new location - your original server data remains untouched until you choose to remove it.

## Prerequisites

Before starting the migration, ensure you have:

1. **Docker installed** on your system
   - Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Linux: Follow [Docker installation guide](https://docs.docker.com/engine/install/)
   - macOS: [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)

2. **Docker Compose** (usually included with Docker Desktop)
   - Verify with: `docker compose version`

3. **Git** installed on your system
   - Required to clone the repository

4. **Backup of your existing server**
   - **IMPORTANT**: Always backup your world data, configuration files, and mods before migration

## Migration Steps

### Step 1: Stop Your Original Server

First, stop your existing Minecraft server to ensure no files are being written during the migration:

```bash
# If running as a service
sudo systemctl stop minecraft

# Or if running manually, stop the server process
# Use Ctrl+C or kill the Java process
```

### Step 2: Locate Your Server Data

Identify where your current server stores its data. Common locations include:

- **Linux**: `/opt/minecraft`, `/home/user/minecraft`, `~/minecraft-server`
- **Windows**: `C:\minecraft-server`, `C:\Users\YourName\minecraft-server`
- **macOS**: `~/minecraft-server`, `/Applications/minecraft-server`

Your server directory typically contains:
- `world/` or `worlds/` - Your world data
- `mods/` - Installed mods
- `config/` - Mod configuration files
- `server.properties` - Server settings
- `ops.json` or `ops.txt` - Operator list
- `whitelist.json` - Whitelist (if enabled)
- `banned-players.json` - Banned players
- `banned-ips.json` - Banned IPs
- `usercache.json` - User cache
- `logs/` - Server logs

### Step 3: Choose Your Deployment Method

You have two options for deploying the Infernos server:

#### Option A: Deploy with Portainer (Recommended)

Portainer can deploy directly from your Git repository, handling cloning and building automatically.

1. **Open Portainer** and navigate to **Stacks**
2. Click **Add stack**
3. Select **Repository** as the deployment method
4. Configure the Git repository:
   - **Repository URL**: `https://github.com/Infernos-ZA/infernos-minecraft-server`
   - **Compose path**: `docker-compose-infernos.yml`
   - **Repository reference**: `master` (or your branch name)
   - **Auto-update**: Enable if you want automatic updates on push
5. Click **Deploy the stack**

Portainer will automatically:
- Clone the repository
- Build the Docker image from the Dockerfile
- Deploy the stack with the Infernos configuration

!!! tip "Portainer Auto-Update"
    If you enable auto-update, Portainer will automatically redeploy when changes are pushed to the repository, ensuring you always have the latest Infernos deployment scripts.

#### Option B: Manual Clone and Build

If you prefer to deploy manually or don't use Portainer:

```bash
# Clone the repository
git clone https://github.com/Infernos-ZA/infernos-minecraft-server.git infernos-minecraft-server
cd infernos-minecraft-server

# Build the Docker image
docker build -t infernos-minecraft-server:latest .

# Deploy with docker compose
docker compose -f docker-compose-infernos.yml up -d
```

### Step 4: Create Docker Compose Configuration (Manual Deployment Only)

If you're deploying manually (not using Portainer), create a new directory for your server instance:

```bash
mkdir ~/infernos-server
cd ~/infernos-server
```

Create a `docker-compose.yml` file with the following content:

```yaml
services:
  mc:
    # Build from the cloned repository
    build:
      context: ../infernos-minecraft-server  # Path to the cloned repository
      dockerfile: Dockerfile
    environment:
      EULA: "TRUE"
      TYPE: INFERNOS
      # Optional: Force reinstall of modpack
      # INFERNOS_FORCE_REINSTALL: "false"
      # Optional: Custom manifest URL (defaults to official)
      # INFERNOS_MANIFEST_URL: "https://infernos.co.za/api/launcher/manifest"
    ports:
      - "25565:25565"  # Minecraft server port
      # Add additional ports if needed for mods/plugins
    volumes:
      - ./data:/data
    stdin_open: true
    tty: true
    restart: unless-stopped
```

!!! note "Using Repository Compose File"
    Alternatively, you can use the `docker-compose-infernos.yml` file from the repository directly:
    
    ```bash
    cd infernos-minecraft-server
    docker compose -f docker-compose-infernos.yml up -d
    ```

### Step 5: Migrate Your World Data

The Docker container expects data in `/data` inside the container. You'll need to copy your world data to the new location.

#### Option A: Copy World to New Location (Recommended)

1. Create the data directory:
   ```bash
   mkdir -p ~/infernos-server/data
   ```

2. Copy your world folder:
   ```bash
   # Linux/macOS
   cp -r /path/to/old/server/world ~/infernos-server/data/
   
   # Windows (PowerShell)
   Copy-Item -Path "C:\path\to\old\server\world" -Destination ".\data\world" -Recurse
   ```

3. If you have multiple worlds, copy them all:
   ```bash
   # Linux/macOS
   cp -r /path/to/old/server/world* ~/infernos-server/data/
   ```

#### Option B: Use Existing Directory (Advanced)

If you want to use your existing server directory directly, you can mount it:

```yaml
volumes:
  - /path/to/old/server:/data
```

!!! warning "Backup First"
    Using your existing directory directly means the Docker container will modify it. Make sure you have a backup!

### Step 6: Migrate Configuration Files

Copy important configuration files from your old server to the new data directory:

```bash
# Copy server.properties (if you have custom settings)
cp /path/to/old/server/server.properties ~/infernos-server/data/

# Copy operator list
cp /path/to/old/server/ops.json ~/infernos-server/data/ 2>/dev/null || \
cp /path/to/old/server/ops.txt ~/infernos-server/data/ 2>/dev/null || true

# Copy whitelist
cp /path/to/old/server/whitelist.json ~/infernos-server/data/ 2>/dev/null || true

# Copy ban lists
cp /path/to/old/server/banned-*.json ~/infernos-server/data/ 2>/dev/null || true

# Copy user cache (preserves player UUIDs)
cp /path/to/old/server/usercache.json ~/infernos-server/data/ 2>/dev/null || true
```

### Step 7: Migrate Mod Configurations

If you have custom mod configurations, copy the `config/` directory:

```bash
# Copy entire config directory
cp -r /path/to/old/server/config ~/infernos-server/data/ 2>/dev/null || true
```

!!! note "Modpack Mods"
    The Infernos modpack will automatically download the required server mods based on the manifest. Your old mods in the `mods/` directory will be replaced with the modpack's mods. However, your `config/` directory settings will be preserved.

### Step 8: Start the Docker Server

Start the server for the first time:

```bash
cd ~/infernos-server
docker compose up -d
```

This will:
1. Pull the latest Minecraft server image
2. Fetch the Infernos modpack manifest
3. Install NeoForge (the modloader used by Infernos)
4. Download all server mods from the manifest
5. Start the server

### Step 9: Monitor the Startup

Watch the logs to ensure everything starts correctly:

```bash
docker compose logs -f
```

You should see messages like:
```
[init] Fetching Infernos modpack manifest from https://infernos.co.za/api/launcher/manifest
[init] Manifest details:
[init]   Minecraft version: X.X.X
[init]   Modloader: NeoForge
[init]   Modloader version: X.X.X
[init]   Modpack version: X.X.X
[init] Installing NeoForge...
[init] Downloading server mods...
```

Wait until you see the server fully started (usually indicated by "Done" or "For help, type /help").

### Step 10: Verify Your World

Once the server is running, connect with your Minecraft client to verify:
- Your world loads correctly
- Your player data is intact
- Mods are working properly
- Configuration settings are preserved

## Post-Migration Configuration

### Setting Server Properties via Environment Variables

Instead of editing `server.properties` directly, you can set server properties using environment variables in your `docker-compose.yml`:

```yaml
environment:
  EULA: "TRUE"
  TYPE: INFERNOS
  MOTD: "Welcome to Infernos Server"
  MAX_PLAYERS: "20"
  DIFFICULTY: "normal"
  MODE: "survival"
  PVP: "true"
  # See docs/configuration/server-properties.md for all options
```

### Memory Allocation

Set Java memory limits:

```yaml
environment:
  MEMORY: "4G"  # Adjust based on your server's RAM
```

### Updating the Modpack

The Infernos modpack will automatically check for updates on each server start. To force a reinstall:

```yaml
environment:
  INFERNOS_FORCE_REINSTALL: "true"
```

Or temporarily set it when starting:
```bash
docker compose run --rm -e INFERNOS_FORCE_REINSTALL=true mc
```

## Common Issues and Solutions

### Issue: World Not Loading

**Solution**: Ensure the world directory is correctly copied and has the correct permissions:
```bash
# Linux/macOS
chmod -R 755 ~/infernos-server/data/world
```

### Issue: Mods Not Matching Client

**Solution**: The Infernos modpack automatically manages server mods. Make sure your client is using the same modpack version. The modpack version is stored in `/data/.infernos-version`.

### Issue: Configuration Files Not Working

**Solution**: Some mods may have changed configuration formats. Check the modpack's changelog and update your config files accordingly.

### Issue: Port Already in Use

**Solution**: If port 25565 is already in use, change it in `docker-compose.yml`:
```yaml
ports:
  - "25566:25565"  # Use 25566 on host, 25565 in container
```

### Issue: Permission Denied Errors

**Solution**: On Linux, you may need to adjust file ownership:
```bash
sudo chown -R $USER:$USER ~/infernos-server/data
```

## Maintenance

### Viewing Logs

```bash
# Follow logs in real-time
docker compose logs -f

# View last 100 lines
docker compose logs --tail=100
```

### Stopping the Server

```bash
docker compose stop
```

### Starting the Server

```bash
docker compose start
```

### Restarting the Server

```bash
docker compose restart
```

### Updating the Server Image

#### If Using Portainer

If you deployed with Portainer and enabled **Auto-update**, Portainer will automatically redeploy when you push changes to the repository. You can also manually trigger an update:

1. Go to **Stacks** in Portainer
2. Find your Infernos stack
3. Click **Editor** to view/edit the stack
4. Click **Update the stack** to rebuild from the latest repository version

#### If Using Manual Deployment

To update to the latest version from the repository:

```bash
# Navigate to the repository directory
cd /path/to/infernos-minecraft-server

# Pull the latest changes
git pull

# Rebuild and restart
docker compose -f docker-compose-infernos.yml up -d --build
```

Or if you built the image separately:

```bash
# Rebuild the image
docker build -t infernos-minecraft-server:latest .

# Restart your server
cd ~/infernos-server
docker compose up -d --build
```

### Backing Up

Simply backup the `data/` directory:
```bash
# Create a timestamped backup
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz data/
```

## Differences from Original Setup

### Automatic Mod Management

- **Original**: Manually download and update mods
- **Docker**: Automatically fetches mods from Infernos manifest based on version

### Java Version

- **Original**: You manage Java installation and version
- **Docker**: Java is included in the container image

### Server Updates

- **Original**: Manually download new server jar files
- **Docker**: Update with `docker compose pull && docker compose up -d`

### File Locations

- **Original**: Files scattered in various locations
- **Docker**: All data in one `data/` directory

### Process Management

- **Original**: Use systemd, screen, tmux, or manual process
- **Docker**: Managed by Docker with `restart: unless-stopped`

## Rollback Plan

If you need to rollback to your original server:

1. Stop the Docker server:
   ```bash
   docker compose stop
   ```

2. Copy your world data back:
   ```bash
   cp -r ~/infernos-server/data/world /path/to/old/server/
   ```

3. Copy any updated configuration files back to your original server

4. Start your original server as before

## Additional Resources

- [Main Documentation](../index.md)
- [Server Properties Configuration](../configuration/server-properties.md)
- [Data Directory Management](../data-directory.md)
- [Troubleshooting Guide](../misc/troubleshooting.md)

## Getting Help

If you encounter issues during migration:

1. Check the [troubleshooting guide](../misc/troubleshooting.md)
2. Review Docker logs: `docker compose logs`
3. Check the [GitHub issues](https://github.com/itzg/docker-minecraft-server/issues)
4. Join the [Discord community](https://discord.gg/DXfKpjB)

