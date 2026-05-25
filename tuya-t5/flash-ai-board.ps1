# Flash T5 AI chatbot firmware with retries (COM port from config.bat / COM_PORT env).
# Usage: powershell -ExecutionPolicy Bypass -File tuya-t5\flash-ai-board.ps1

$ErrorActionPreference = "Stop"

$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$py = if ($env:PY) { $env:PY } else { "C:\Users\shivr\AppData\Local\Programs\Python\Python312\python.exe" }
$comPort = if ($env:COM_PORT) { $env:COM_PORT } else { "COM12" }
$available = @([System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object)
if ($available.Count -gt 0 -and $comPort -notin $available) {
    Write-Host "  Warning: $comPort not found. Available: $($available -join ', ')" -ForegroundColor Yellow
    Write-Host "  Edit COM_PORT in config.bat. Trying $comPort anyway..." -ForegroundColor Yellow
}
$app = Join-Path $tuyaOpen "apps\tuya.ai\your_chat_bot"
$tos = Join-Path $tuyaOpen "tos.py"
$binCandidates = @(
    (Join-Path $app ".build\bin\your_chat_bot_QIO_1.0.1.bin"),
    (Join-Path $app "dist\your_chat_bot_1.0.1\your_chat_bot_QIO_1.0.1.bin")
)

$bin = $binCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $bin) {
    Write-Host "Firmware not built. Run BUILD-FLASH-AI-BOARD.bat or option 3 in Run.ps1 first." -ForegroundColor Red
    exit 1
}

$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
$bashBin = Join-Path $tuyaOpen "platform\T5AI\tools\bash\bin"
$gnuWin = "C:\Program Files (x86)\GnuWin32\bin"
$pyDir = Split-Path $py -Parent
$env:PATH = "$pyDir;$pyDir\Scripts;$gnuWin;$bashBin;$env:PATH"

Write-Host ""
Write-Host "Flash AI board on $comPort" -ForegroundColor Cyan
Write-Host "Firmware: $bin"
Write-Host ""
Write-Host "Before each attempt:" -ForegroundColor Yellow
Write-Host "  1. Use a USB DATA cable (not charge-only)."
Write-Host "  2. Close Serial Monitor / Arduino IDE / other tools using $comPort."
Write-Host "  3. When the tool shows 'Waiting Reset', press the RST button on the board once."
Write-Host "     (If it still fails: hold BOOT, tap RST, release BOOT, then press Enter here.)"
Write-Host ""

$maxAttempts = 3
Push-Location $app
try {
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        Write-Host "--- Flash attempt $attempt of $maxAttempts ---" -ForegroundColor Cyan
        if ($attempt -gt 1) {
            Write-Host "Unplug USB, wait 2 seconds, plug back in, then continue." -ForegroundColor Yellow
        }
        Read-Host "Press Enter to start flash (then press RST when you see Waiting Reset)"

        & $py $tos flash -p $comPort -b 115200
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "FLASH SUCCESS" -ForegroundColor Green
            Write-Host "Open Tuya Smart app to connect the board to WiFi."
            exit 0
        }
        Write-Host "Flash attempt $attempt failed." -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "FLASH FAILED after $maxAttempts attempts." -ForegroundColor Red
    Write-Host "Check COM port in config.bat (Device Manager). Ports seen now:" -ForegroundColor Yellow
    [System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object | ForEach-Object { Write-Host "  $_" }
    exit 1
}
finally {
    Pop-Location
}
