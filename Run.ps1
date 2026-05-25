# FreshrFridge — run everything from PowerShell:  .\Run.ps1
$ErrorActionPreference = "Stop"
$Repo = $PSScriptRoot
$ComPort = "COM12"

function Show-Menu {
    Write-Host ""
    Write-Host "=== FreshrFridge ===" -ForegroundColor Cyan
    Write-Host "  Board COM port: $ComPort  (edit `$ComPort in Run.ps1 to change)"
    Write-Host ""
    Write-Host "  0  Check setup (paths, backend, firmware)"
    Write-Host "  1  Start web app (browser UI)"
    Write-Host "  2  Start AI + database server (port 3000)"
    Write-Host "  3  Build + flash AI board (WiFi + voice, English)"
    Write-Host "  4  Flash AI board only (skip rebuild, COM12)"
    Write-Host "  5  Build + flash fridge touch UI"
    Write-Host "  6  Flash fridge UI only"
    Write-Host "  Q  Quit"
    Write-Host ""
}

function Ensure-BackendEnv {
    $groq = Join-Path (Split-Path $Repo -Parent) "Groq"
    if (-not (Test-Path "$groq\.env")) {
        if (Test-Path "$groq\.env.example") {
            Copy-Item "$groq\.env.example" "$groq\.env"
            Write-Host "Created Groq\.env — add your GROQ_API_KEY there." -ForegroundColor Yellow
        } else {
            throw "Groq backend missing at $groq"
        }
    }
    if (-not (Test-Path "$groq\node_modules")) {
        Push-Location $groq
        npm install
        Pop-Location
    }
}

function Start-Web {
    Push-Location $Repo
    if (-not (Test-Path "node_modules")) { npm install }
    Write-Host "Web: http://localhost:5173" -ForegroundColor Green
    npm run dev
}

function Start-Backend {
    Ensure-BackendEnv
    $groq = Join-Path (Split-Path $Repo -Parent) "Groq"
    Push-Location $groq
    Write-Host "Backend: http://localhost:3000/health" -ForegroundColor Green
    npm start
}

function Build-Flash-AiBoard {
    $env:COM_PORT = $ComPort
    & (Join-Path $Repo "BUILD-FLASH-AI-BOARD.bat")
}

function Flash-AiBoardOnly {
    $env:COM_PORT = $ComPort
    $env:TUYA_OPEN_ROOT = "C:\Users\shivr\TuyaOpen"
    $env:PY = "C:\Users\shivr\AppData\Local\Programs\Python\Python312\python.exe"
    & (Join-Path $Repo "tuya-t5\flash-ai-board.ps1")
}

function Build-Flash-Fridge {
    $env:COM_PORT = $ComPort
    & (Join-Path $Repo "BUILD-FIRMWARE.bat")
    if ($LASTEXITCODE -ne 0) { return }
    & (Join-Path $Repo "FLASH-FIRMWARE.bat")
}

function Flash-FridgeOnly {
    $env:COM_PORT = $ComPort
    & (Join-Path $Repo "FLASH-FIRMWARE.bat")
}

do {
    Show-Menu
    $choice = Read-Host "Choice"
    switch ($choice.Trim().ToUpper()) {
        "0" { & (Join-Path $Repo "CHECK-SETUP.bat"); pause; break }
        "1" { Start-Web; break }
        "2" { Start-Backend; break }
        "3" { Build-Flash-AiBoard; break }
        "4" { Flash-AiBoardOnly; pause; break }
        "5" { Build-Flash-Fridge; break }
        "6" { Flash-FridgeOnly; break }
        "Q" { break }
        default { Write-Host "Invalid choice." -ForegroundColor Yellow }
    }
} while ($choice.Trim().ToUpper() -ne "Q")
