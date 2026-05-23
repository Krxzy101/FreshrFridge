@echo off
REM One-click: copy sources, merge secrets, build FreshrFridge firmware
setlocal
set PY=C:\Users\shivr\AppData\Local\Programs\Python\Python312\python.exe
set TOS=C:\Users\shivr\TuyaOpen\tos.py
set APP=C:\Users\shivr\TuyaOpen\examples\freshrfridge
set SRC=%~dp0tuya-t5\freshrfridge

if not exist "%PY%" (
    echo Python 3.12 not found. Install from https://www.python.org/downloads/
    pause
    exit /b 1
)

if not exist "%TOS%" (
    echo TuyaOpen not found at C:\Users\shivr\TuyaOpen
    pause
    exit /b 1
)

if not exist "%SRC%\config\device_secrets.config" (
    echo.
    echo  Create %SRC%\config\device_secrets.config first
    echo  ^(copy from device_secrets.config.example and add uuid + key^)
    echo.
    pause
    exit /b 1
)

echo Copying freshrfridge...
xcopy /E /I /Y "%SRC%\*" "%APP%\" >nul
call "%APP%\config\merge-secrets.bat"

if not exist "%PY:\python.exe=python3.exe%" (
    copy /Y "%PY%" "%PY:\python.exe=python3.exe%" >nul
)

set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set PATH=C:\Users\shivr\AppData\Local\Programs\Python\Python312;C:\Users\shivr\AppData\Local\Programs\Python\Python312\Scripts;C:\Program Files (x86)\GnuWin32\bin;C:\Users\shivr\TuyaOpen\platform\T5AI\tools\bash\bin;%PATH%

echo Building ^(5-10 minutes first time^)...
cd /d "%APP%"
"%PY%" "%TOS%" build
if errorlevel 1 (
    echo BUILD FAILED
    pause
    exit /b 1
)

echo.
echo BUILD SUCCESS
echo Firmware: %APP%\dist\
echo.
echo Next: plug in T5 board USB, run FLASH-FIRMWARE.bat
pause
