@echo off
REM Build AI board firmware only (no flash). Use FLASH-AI-BOARD.bat after.
setlocal EnableExtensions
call "%~dp0config.bat"

set "REPO=%~dp0"
set "TOS=%TUYA_OPEN%\tos.py"
set "APP=%TUYA_OPEN%\apps\tuya.ai\your_chat_bot"

echo.
echo === Build AI board firmware only (no flash) ===
echo.

if not exist "%REPO%tuya-t5\freshrfridge\config\device_secrets.config" (
    echo ERROR: Missing device_secrets.config
    goto fail
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\patch-english-lang.ps1"
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\patch-enable-emoji-ui.ps1"
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\merge-chatbot-secrets.ps1"
if errorlevel 1 goto fail
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\clean-ai-build.ps1"
if errorlevel 1 goto fail

echo Building - usually 3-8 minutes...
cd /d "%APP%"
"%PY%" "%TOS%" build
if errorlevel 1 goto fail

echo.
echo BUILD OK - run FLASH-AI-BOARD.bat when the board is plugged in.
goto done

:fail
echo BUILD FAILED
:done
pause
endlocal
