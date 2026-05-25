# Merges device_secrets into chat bot configs (board + app_default for build).
# Usage: powershell -ExecutionPolicy Bypass -File tuya-t5\merge-chatbot-secrets.ps1

$ErrorActionPreference = "Stop"

function Write-ConfigNoBom {
    param([string[]]$Lines, [string]$Path)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($Path, $Lines, $utf8NoBom)
}

$here = $PSScriptRoot
$secretsFile = Join-Path $here "freshrfridge\config\device_secrets.config"
$baseTemplate = Join-Path $here "chatbot-board.config"
$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$appRoot = Join-Path $tuyaOpen "apps\tuya.ai\your_chat_bot"
$boardFile = Join-Path $appRoot "config\TUYA_T5AI_BOARD_LCD_3.5.config"
$appDefault = Join-Path $appRoot "app_default.config"

if (-not (Test-Path $secretsFile)) {
    Write-Host "  device_secrets.config not found." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $appRoot)) {
    Write-Host "  your_chat_bot not found: $appRoot" -ForegroundColor Red
    exit 1
}

$secretLines = Get-Content $secretsFile | Where-Object {
    $_ -match '^\s*CONFIG_TUYA_' -and $_ -notmatch '^\s*#'
}

$baseLines = @()
if (Test-Path $baseTemplate) {
    $baseLines = Get-Content $baseTemplate | Where-Object {
        $_ -match '^\s*CONFIG_' -or $_ -match '^\s*#\s*CONFIG_'
    } | Where-Object {
        $_ -notmatch '^\s*CONFIG_TUYA_PRODUCT_ID' -and
        $_ -notmatch '^\s*CONFIG_TUYA_DEVICE_UUID' -and
        $_ -notmatch '^\s*CONFIG_TUYA_DEVICE_AUTHKEY'
    }
}

$merged = $baseLines + $secretLines
Write-ConfigNoBom -Lines $merged -Path $boardFile
Write-ConfigNoBom -Lines $merged -Path $appDefault

Write-Host "  Chat bot config updated (WiFi + voice + English):" -ForegroundColor Green
Write-Host "    $boardFile"
Write-Host "    $appDefault"
