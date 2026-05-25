@echo off
REM Flash AI board only - no rebuild - COM12
setlocal EnableExtensions
call "%~dp0config.bat"

set "TOS=%TUYA_OPEN%\tos.py"
set "APP=%TUYA_OPEN%\apps\tuya.ai\your_chat_bot"
echo.
echo === Flash AI board on %COM_PORT% ===
echo.

if not exist "%PY%" (
    echo ERROR: Python not found at %PY%
    goto fail
)

set "COM_PORT=%COM_PORT%"
set "PY=%PY%"
set "TUYA_OPEN_ROOT=%TUYA_OPEN%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tuya-t5\flash-ai-board.ps1"
if errorlevel 1 goto fail

echo FLASH SUCCESS
goto done

:fail
echo FLASH FAILED
:done
pause
endlocal
