# Fix Docker Desktop WSL Issue

## Quick Fixes to Try:

### 1. Restart WSL
```powershell
wsl --shutdown
```
Then restart Docker Desktop.

### 2. Check WSL Status
```powershell
wsl --list --verbose
```
Make sure you have at least one WSL2 distro installed and running.

### 3. Update WSL
```powershell
wsl --update
```

### 4. Reset Docker Desktop WSL Integration
1. Open Docker Desktop Settings
2. Go to Resources → WSL Integration
3. Uncheck "Arch" (or all distros)
4. Apply & Restart
5. Re-enable the distro
6. Apply & Restart again

### 5. Use Windows Containers (Temporary Workaround)
1. Docker Desktop Settings
2. General → Use Windows containers instead of Linux containers
3. Apply & Restart

### 6. Complete Reset (Last Resort)
```powershell
# Stop Docker
Stop-Service com.docker.service

# Reset Docker Desktop
Remove-Item "$env:LOCALAPPDATA\Docker" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:ProgramData\DockerDesktop" -Recurse -Force -ErrorAction SilentlyContinue

# Restart Docker Desktop
```

