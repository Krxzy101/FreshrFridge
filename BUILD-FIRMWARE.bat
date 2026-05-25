@echo off
setlocal EnableExtensions
call "%~dp0config.bat"

set "REPO=%~dp0"
set "TOS=%TUYA_OPEN%\tos.py"
set "APP=%TUYA_OPEN%\examples\freshrfridge"
set "SRC=%REPO%tuya-t5\freshrfridge"

echo.
echo === Build FreshrFridge touch UI firmware ===
echo.

if not exist "%SRC%\config\device_secrets.config" (
    echo ERROR: Missing device_secrets.config
    goto fail
)

if not exist "%PY%" (
    echo ERROR: Python not found at %PY%
    goto fail
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\deploy-to-tuyaopen.ps1"
if errorlevel 1 goto fail

echo Building...
cd /d "%APP%"
"%PY%" "%TOS%" build
if errorlevel 1 goto fail

echo.
echo BUILD OK - run FLASH-FIRMWARE.bat on port %COM_PORT%
goto done

:fail
echo BUILD FAILED
:done
pause
endlocal
