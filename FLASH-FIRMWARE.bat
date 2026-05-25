@echo off
setlocal EnableExtensions
call "%~dp0config.bat"

set "TOS=%TUYA_OPEN%\tos.py"
set "APP=%TUYA_OPEN%\examples\freshrfridge"
set "BIN=%APP%\.build\bin\freshrfridge_QIO_1.0.0.bin"

echo.
echo === Flash fridge UI on %COM_PORT% ===
echo.

if not exist "%BIN%" (
    echo ERROR: Run BUILD-FIRMWARE.bat first.
    goto fail
)

if not exist "%PY%" (
    echo ERROR: Python not found at %PY%
    goto fail
)

echo When you see Waiting Reset, press RST on the board.
pause
cd /d "%APP%"
"%PY%" "%TOS%" flash -p %COM_PORT% -b 115200
if errorlevel 1 goto fail

echo FLASH SUCCESS - green FreshrFridge screen
goto done

:fail
echo FLASH FAILED - check USB and COM port in config.bat
:done
pause
endlocal
