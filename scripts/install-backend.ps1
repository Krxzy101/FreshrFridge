# Copies Groq backend into Website\Groq (sibling of FreshrFridge).
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$dst = Join-Path (Split-Path $repo -Parent) "Groq"
$src = "C:\Users\shivr\Downloads\Website2\Website\Website\Groq"

New-Item -ItemType Directory -Force -Path $dst | Out-Null

if (Test-Path (Join-Path $src "server.js")) {
    @("server.js", "package.json", "package-lock.json", ".env.example") | ForEach-Object {
        Copy-Item (Join-Path $src $_) (Join-Path $dst $_) -Force
    }
    if (-not (Test-Path (Join-Path $dst ".env")) -and (Test-Path (Join-Path $src ".env"))) {
        Copy-Item (Join-Path $src ".env") (Join-Path $dst ".env") -Force
    }
    Write-Host "Copied backend from Downloads to $dst" -ForegroundColor Green
} else {
    Write-Host "Source not found at $src" -ForegroundColor Red
    Write-Host "Create $dst manually with server.js from the project docs."
    exit 1
}

Push-Location $dst
npm install
Pop-Location
Write-Host "Done. Run START-BACKEND.bat" -ForegroundColor Green
