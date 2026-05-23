@echo off
REM One-click: copy FreshrFridge into TuyaOpen + merge secrets
set SRC=%~dp0tuya-t5\freshrfridge
set DST=C:\Users\shivr\TuyaOpen\examples\freshrfridge

if not exist "C:\Users\shivr\TuyaOpen\tos.py" (
    echo.
    echo  TuyaOpen not found at C:\Users\shivr\TuyaOpen
    echo  Clone it first: git clone https://github.com/tuya/TuyaOpen.git C:\Users\shivr\TuyaOpen
    echo.
    pause
    exit /b 1
)

if not exist "%SRC%" (
    echo Source not found: %SRC%
    pause
    exit /b 1
)

echo Copying freshrfridge to TuyaOpen...
xcopy /E /I /Y "%SRC%" "%DST%\" >nul

if not exist "%DST%\config\device_secrets.config" (
    echo.
    echo  Create device_secrets.config first:
    echo  Copy config\device_secrets.config.example to device_secrets.config
    echo  and paste your uuid + key from the Tuya license sheet.
    echo.
    pause
    exit /b 1
)

echo Merging secrets into board config...
powershell -NoProfile -ExecutionPolicy Bypass -File "%DST%\config\merge-secrets.ps1"

echo.
echo  Done! FreshrFridge is at:
echo  %DST%
echo.
echo  Next: open PowerShell in C:\Users\shivr\TuyaOpen and run build steps
echo  (requires Python or WSL - see SETUP-NEXT-STEPS.txt in FreshrFridge folder)
echo.
pause
