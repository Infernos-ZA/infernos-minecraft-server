# Wait for Docker to be ready, then run Infernos test
Write-Host "Waiting for Docker Desktop to be ready..."
$maxWait = 120
$elapsed = 0
$ready = $false

while ($elapsed -lt $maxWait -and -not $ready) {
    try {
        $null = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            $ready = $true
            Write-Host "`nDocker is ready! Starting Infernos test...`n" -ForegroundColor Green
            break
        }
    } catch {
        # Docker not ready yet
    }
    
    Start-Sleep -Seconds 2
    $elapsed += 2
    Write-Host "." -NoNewline
}

if (-not $ready) {
    Write-Host "`nDocker did not become ready within $maxWait seconds." -ForegroundColor Red
    Write-Host "Please ensure Docker Desktop is running and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nBuilding Docker image..."
docker-compose -f docker-compose-infernos-test.yml build

Write-Host "`nRunning Infernos setup (SETUP_ONLY mode)...`n"
docker-compose -f docker-compose-infernos-test.yml run --rm mc sh -c "export SETUP_ONLY=TRUE && /start"

Write-Host "`n=== Setup Complete! Checking results... ===`n"
docker-compose -f docker-compose-infernos-test.yml run --rm mc sh -c @"
echo '=== Mods directory ==='
ls -lh /data/mods/ 2>/dev/null | head -20 || echo 'No mods found'
echo ''
echo '=== Mod count ==='
find /data/mods -name '*.jar' 2>/dev/null | wc -l
echo ''
echo '=== Version file ==='
cat /data/.infernos-version 2>/dev/null || echo 'No version file'
echo ''
echo '=== NeoForge check ==='
ls -lh /data/neoforge-*.jar 2>/dev/null || ls -lh /data/run.sh 2>/dev/null || echo 'NeoForge files not found'
"@

Write-Host "`n=== Test Complete ===`n" -ForegroundColor Green

