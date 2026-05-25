@echo off
REM Build + flash Tuya AI chat bot - WiFi + speakers + English - COM12
setlocal EnableExtensions
call "%~dp0config.bat"

set "REPO=%~dp0"
set "TOS=%TUYA_OPEN%\tos.py"
set "APP=%TUYA_OPEN%\apps\tuya.ai\your_chat_bot"

echo.
echo === T5 AI board: WiFi + voice, English, port %COM_PORT% ===
echo.

if not exist "%REPO%tuya-t5\freshrfridge\config\device_secrets.config" (
    echo ERROR: Missing device_secrets.config
    echo Copy device_secrets.config.example and add uuid + key.
    goto fail
)

if not exist "%APP%" (
    echo ERROR: your_chat_bot not found at %APP%
    goto fail
)

if not exist "%PY%" (
    echo ERROR: Python not found at %PY%
    goto fail
)

echo [1/6] English UI...
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\patch-english-lang.ps1"
if errorlevel 1 goto fail

echo [2/6] Emoji UI + WiFi settings screen...
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\patch-enable-emoji-ui.ps1"
if errorlevel 1 goto fail

echo [3/6] Board config + license...
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\merge-chatbot-secrets.ps1"
if errorlevel 1 goto fail

echo [4/6] Clean old build folder...
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\clean-ai-build.ps1"
if errorlevel 1 goto fail

echo [5/6] Building firmware - usually 3-8 minutes, do not close this window...
cd /d "%APP%"
"%PY%" "%TOS%" build
if errorlevel 1 goto fail

if not exist "%APP%\.build\bin\your_chat_bot_QIO_1.0.1.bin" (
    if not exist "%APP%\dist\your_chat_bot_1.0.1\your_chat_bot_QIO_1.0.1.bin" (
        echo ERROR: Build finished but firmware .bin not found.
        goto fail
    )
)

echo [6/6] Flashing on %COM_PORT%...
set "COM_PORT=%COM_PORT%"
set "PY=%PY%"
set "TUYA_OPEN_ROOT=%TUYA_OPEN%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\flash-ai-board.ps1"
if errorlevel 1 goto fail

echo.
echo DONE - Flash success. Use Tuya app to connect WiFi.
goto done

:fail
echo.
echo FAILED - see messages above. COM port is %COM_PORT% - edit config.bat to change.
:done
echo.
pause
endlocal
