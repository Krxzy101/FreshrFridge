# Merges device_secrets.config into TUYA_T5AI_BOARD_LCD_3.5.config
# Run from anywhere:  powershell -File merge-secrets.ps1

$here = $PSScriptRoot
$secretsFile = Join-Path $here "device_secrets.config"
$boardFile = Join-Path $here "TUYA_T5AI_BOARD_LCD_3.5.config"

if (-not (Test-Path $secretsFile)) {
    Write-Host ""
    Write-Host "  device_secrets.config not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "  1. Copy device_secrets.config.example -> device_secrets.config"
    Write-Host "  2. Fill in your uuid and key from the Tuya license sheet"
    Write-Host "  3. Run this script again"
    Write-Host ""
    exit 1
}

if (-not (Test-Path $boardFile)) {
    Write-Host "  Board config not found: $boardFile" -ForegroundColor Red
    exit 1
}

$secretLines = Get-Content $secretsFile | Where-Object {
    $_ -match '^\s*CONFIG_TUYA_' -and $_ -notmatch '^\s*#'
}

if ($secretLines.Count -lt 3) {
    Write-Host "  device_secrets.config must have PRODUCT_ID, UUID, and AUTHKEY lines." -ForegroundColor Red
    exit 1
}

$baseLines = Get-Content $boardFile | Where-Object {
    $_ -notmatch '^\s*CONFIG_TUYA_PRODUCT_ID' -and
    $_ -notmatch '^\s*CONFIG_TUYA_DEVICE_UUID' -and
    $_ -notmatch '^\s*CONFIG_TUYA_DEVICE_AUTHKEY'
}

($baseLines + $secretLines) | Set-Content -Path $boardFile -Encoding utf8

Write-Host ""
Write-Host "  Done! Credentials merged into:" -ForegroundColor Green
Write-Host "  $boardFile"
Write-Host ""
Write-Host "  Next: run BUILD-FIRMWARE.bat in the FreshrFridge folder."
Write-Host ""
