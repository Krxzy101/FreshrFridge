# Stops stuck builds and deletes .build so ninja can run cleanly.
$ErrorActionPreference = "SilentlyContinue"

$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$buildDir = Join-Path $tuyaOpen "apps\tuya.ai\your_chat_bot\.build"

Write-Host "Stopping any stuck build tools..."
Get-Process ninja, cmake -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

if (Test-Path $buildDir) {
    Write-Host "Removing old build folder..."
    Remove-Item -Recurse -Force $buildDir
    Start-Sleep -Seconds 1
    if (Test-Path $buildDir) {
        Write-Host "Could not delete .build - close other terminals and try again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Build folder cleared." -ForegroundColor Green
