@echo off
REM Copy FreshrFridge firmware into TuyaOpen and merge device secrets
setlocal
set "REPO=%~dp0"
set "SRC=%REPO%tuya-t5\freshrfridge"
set "TUYA_OPEN=C:\Users\shivr\TuyaOpen"
set "DST=%TUYA_OPEN%\examples\freshrfridge"

if defined TUYA_OPEN_ROOT set "TUYA_OPEN=%TUYA_OPEN_ROOT%"

if not exist "%TUYA_OPEN%\tos.py" (
    echo.
    echo  TuyaOpen not found at %TUYA_OPEN%
    echo  Clone: git clone https://github.com/tuya/TuyaOpen %TUYA_OPEN%
    echo.
    pause
    exit /b 1
)

if not exist "%SRC%" (
    echo Source not found: %SRC%
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO%tuya-t5\deploy-to-tuyaopen.ps1"
if errorlevel 1 pause & exit /b 1

echo.
echo  Done. Firmware sources are at:
echo  %DST%
echo.
echo  Next: run BUILD-FIRMWARE.bat
echo.
pause
endlocal
