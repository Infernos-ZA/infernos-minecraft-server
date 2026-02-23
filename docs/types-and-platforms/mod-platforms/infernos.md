# Infernos Modpack

The [Infernos](https://infernos.co.za) modpack can be automatically installed by setting `MODPACK_PLATFORM`, `MOD_PLATFORM` or `TYPE` to "INFERNOS". This will automatically fetch the modpack manifest, install the required modloader (NeoForge), and download all server-side mods.

## How It Works

When `TYPE=INFERNOS` is set, the container will:

1. Fetch the modpack manifest from the Infernos API
2. Parse the manifest to determine:
   - Minecraft version
   - Modloader type and version (currently NeoForge)
   - Modpack version
   - List of server mods to download
3. Install NeoForge for the specified Minecraft version
4. Download all mods tagged with "server" from the manifest
5. Verify mod integrity using SHA1 checksums (when provided)

!!! important "Data Safety"
    The Infernos deployment **never deletes** your existing data:
    - World data, player data, and configuration files are **always preserved**
    - Mods are only **added or updated** - existing mods not in the manifest remain untouched
    - The script uses `ensureRemoveAllModsOff` to prevent automatic mod deletion
    - Only mods from the manifest are downloaded/updated when the modpack version changes

## Installation

This Infernos-enabled server must be built from the source repository. It is not available as a pre-built image on Docker Hub.

### Option 1: Deploy with Portainer (Recommended)

Portainer can deploy directly from your Git repository, automatically handling cloning and building:

1. **Open Portainer** and navigate to **Stacks**
2. Click **Add stack**
3. Select **Repository** as the deployment method
4. Configure the Git repository:
   - **Repository URL**: `https://github.com/Infernos-ZA/infernos-minecraft-server`
   - **Compose path**: `docker-compose-infernos.yml`
   - **Repository reference**: `master` (or your branch name)
   - **Auto-update**: Enable for automatic updates on push
5. Click **Deploy the stack**

Portainer will automatically clone the repository, build the image, and deploy the stack.

!!! tip "Portainer Benefits"
    - No manual cloning or building required
    - Automatic updates when enabled
    - Easy management through Portainer UI
    - Built-in logging and monitoring

### Option 2: Manual Build

If you prefer to build manually:

```bash
# Clone the repository
git clone https://github.com/Infernos-ZA/infernos-minecraft-server.git infernos-minecraft-server
cd infernos-minecraft-server

# Build the Docker image
docker build -t infernos-minecraft-server:latest .

# Or deploy directly with compose
docker compose -f docker-compose-infernos.yml up -d
```

## Basic Usage

The simplest setup uses the `docker-compose-infernos.yml` file from the repository, which builds from the Dockerfile:

```yaml
services:
  mc:
    build:
      context: .  # When using the compose file from the repo
      dockerfile: Dockerfile
    environment:
      EULA: "TRUE"
      TYPE: INFERNOS
    ports:
      - "25565:25565"
    volumes:
      - infernos-data:/data
    stdin_open: true
    tty: true
    restart: unless-stopped

volumes:
  infernos-data:
```

When deploying with Portainer from Git, this compose file is used automatically. For manual deployment:

```bash
cd infernos-minecraft-server
docker compose -f docker-compose-infernos.yml up -d
```

## Configuration Options

### Manifest URL

By default, the container fetches the manifest from:
```
https://infernos.co.za/api/launcher/manifest
```

You can override this with the `INFERNOS_MANIFEST_URL` environment variable:

```yaml
environment:
  TYPE: INFERNOS
  INFERNOS_MANIFEST_URL: "https://custom-url.com/manifest.json"
```

### Force Reinstall

By default, the modpack will only update mods when the modpack version changes. To force a complete reinstall of all mods, set `INFERNOS_FORCE_REINSTALL` to `"true"`:

```yaml
environment:
  TYPE: INFERNOS
  INFERNOS_FORCE_REINSTALL: "true"
```

!!! note "Version Tracking"
    The modpack version is stored in `/data/.infernos-version`. The container compares this with the version in the manifest to determine if an update is needed.

## Manifest Format

The Infernos manifest is a JSON file that contains:

- `mc_version`: The Minecraft version (e.g., "1.20.1")
- `modloader`: The modloader type (currently "NEOFORGE")
- `modloader_version`: The modloader version
- `modpack_version`: The modpack version string
- `mods`: An array of mod objects, each containing:
  - `filename`: The mod filename
  - `download_url`: URL to download the mod
  - `sha1`: SHA1 checksum for verification (optional)
  - `tags`: Array of tags (mods with "server" tag are downloaded)

## Mod Management

### Automatic Updates

The modpack automatically checks for updates on each server start. If the modpack version in the manifest differs from the stored version, all server mods will be updated.

### Mod Filtering

Only mods with the "server" tag in the manifest are downloaded to the server. Client-only mods are automatically excluded.

### Mod Verification

When SHA1 checksums are provided in the manifest, downloaded mods are verified before installation. If verification fails, the server startup will abort with an error.

## Version Information

You can check the currently installed modpack version by examining:

```bash
docker compose exec mc cat /data/.infernos-version
```

Or from within the container:

```bash
cat /data/.infernos-version
```

## Troubleshooting

### Manifest Fetch Fails

If the manifest cannot be fetched, check:

1. **Network connectivity**: Ensure the container can reach `https://infernos.co.za`
2. **URL correctness**: Verify `INFERNOS_MANIFEST_URL` if using a custom URL
3. **DNS resolution**: Ensure DNS is working inside the container

### Mods Not Downloading

If mods aren't being downloaded:

1. Check the logs for errors: `docker compose logs mc`
2. Verify the manifest contains mods with the "server" tag
3. Check if `INFERNOS_FORCE_REINSTALL` is needed
4. Verify the modpack version changed (check `/data/.infernos-version`)

### SHA1 Verification Failures

If SHA1 verification fails:

1. The download may have been corrupted - the container will retry on next start
2. The manifest may have an incorrect SHA1 - contact Infernos support
3. Check network stability during download

### Unsupported Modloader

Currently, only NeoForge is supported. If the manifest specifies a different modloader, the container will exit with an error:

```
Unsupported modloader: <modloader>. Only NeoForge is currently supported.
```

## Migration from Manual Setup

If you're migrating from a manually-configured server, see the [Infernos Migration Guide](../../misc/infernos-migration.md) for detailed instructions.

## Example docker-compose.yml

Here's a complete example with common configurations. This can be used in Portainer or for manual deployment:

```yaml
services:
  mc:
    build:
      context: .  # When using from the repository root
      dockerfile: Dockerfile
    environment:
      EULA: "TRUE"
      TYPE: INFERNOS
      # Server properties
      MOTD: "Welcome to Infernos Server"
      MAX_PLAYERS: "20"
      DIFFICULTY: "normal"
      MODE: "survival"
      # Memory allocation
      MEMORY: "4G"
      # Optional: Force reinstall (set to "false" or remove to disable)
      # INFERNOS_FORCE_REINSTALL: "false"
    ports:
      - "25565:25565"
    volumes:
      - infernos-data:/data
    stdin_open: true
    tty: true
    restart: unless-stopped

volumes:
  infernos-data:
```

!!! tip "Portainer Deployment"
    When deploying via Portainer from Git, specify `docker-compose-infernos.yml` as the compose path. Portainer will automatically use the correct build context.

## Related Documentation

- [Migration Guide](../../misc/infernos-migration.md) - Step-by-step guide for migrating from a traditional server setup
- [Server Properties](../../configuration/server-properties.md) - Configure server settings via environment variables
- [Data Directory](../../data-directory.md) - Understanding the data directory structure
- [Troubleshooting](../../misc/troubleshooting.md) - General troubleshooting guide

