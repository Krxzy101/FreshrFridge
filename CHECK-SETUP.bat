@echo off
REM Quick check: backend, web deps, Tuya paths, firmware bin
setlocal EnableExtensions
call "%~dp0config.bat"
set "REPO=%~dp0"
set "GROQ=%REPO%..\Groq"
set "OK=1"

echo.
echo === FreshrFridge setup check ===
echo.

if exist "%GROQ%\server.js" (
    echo [OK] Backend at %GROQ%
) else (
    echo [FAIL] Backend missing. Expected: %GROQ%\server.js
    echo        Run: powershell -File "%REPO%scripts\install-backend.ps1"
    set "OK=0"
)

if exist "%GROQ%\.env" (
    echo [OK] Groq .env exists
) else (
    echo [WARN] No %GROQ%\.env - copy .env.example and set GROQ_API_KEY
)

if exist "%REPO%node_modules" (echo [OK] Web dependencies) else (echo [WARN] Run: npm install in FreshrFridge)

if exist "%TUYA_OPEN%\tos.py" (echo [OK] TuyaOpen: %TUYA_OPEN%) else (
    echo [FAIL] TuyaOpen not found at %TUYA_OPEN%
    set "OK=0"
)

if exist "%REPO%tuya-t5\freshrfridge\config\device_secrets.config" (echo [OK] device_secrets.config) else (
    echo [FAIL] Missing tuya-t5\freshrfridge\config\device_secrets.config
    set "OK=0"
)

set "FW=%TUYA_OPEN%\apps\tuya.ai\your_chat_bot\.build\bin\your_chat_bot_QIO_1.0.1.bin"
if exist "%FW%" (echo [OK] AI firmware built) else (echo [WARN] No firmware yet - run BUILD-FLASH-AI-BOARD.bat)

echo.
echo COM ports:
powershell -NoProfile -Command "[System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object | ForEach-Object { Write-Host '  ' $_ }"
echo   Edit config.bat if your board is not %COM_PORT%
echo.

if "%OK%"=="0" (
    echo RESULT: Fix FAIL items above, then run CHECK-SETUP.bat again.
) else (
    echo RESULT: Ready. See SETUP-NEXT-STEPS.txt
)
echo.
pause
endlocal
