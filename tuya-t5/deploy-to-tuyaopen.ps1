# Copies freshrfridge into TuyaOpen/examples/freshrfridge and merges device secrets.
# Usage: powershell -ExecutionPolicy Bypass -File tuya-t5\deploy-to-tuyaopen.ps1

$ErrorActionPreference = "Stop"

$here = $PSScriptRoot
$src = Join-Path $here "freshrfridge"
$repoRoot = Split-Path $here -Parent
$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$dst = Join-Path $tuyaOpen "examples\freshrfridge"

if (-not (Test-Path $tuyaOpen)) {
    Write-Host "TuyaOpen not found at: $tuyaOpen" -ForegroundColor Red
    Write-Host "Set TUYA_OPEN_ROOT or clone https://github.com/tuya/TuyaOpen to C:\Users\shivr\TuyaOpen"
    exit 1
}

if (-not (Test-Path $src)) {
    Write-Host "Source not found: $src" -ForegroundColor Red
    exit 1
}

$secrets = Join-Path $src "config\device_secrets.config"
if (-not (Test-Path $secrets)) {
    Write-Host ""
    Write-Host "  Missing device_secrets.config" -ForegroundColor Red
    Write-Host "  Copy config\device_secrets.config.example and add your Tuya uuid + key."
    Write-Host ""
    exit 1
}

& (Join-Path $src "config\merge-secrets.ps1")

if (Test-Path $dst) {
    Remove-Item -Recurse -Force $dst
}
New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
Copy-Item -Recurse -Force $src $dst

Write-Host ""
Write-Host "  Deployed freshrfridge -> $dst" -ForegroundColor Green
Write-Host ""
