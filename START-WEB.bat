@echo off
REM Start FreshrFridge web app (Vite dev server, port 5173)
setlocal
cd /d "%~dp0"

if not exist "node_modules" (
    echo Installing web dependencies...
    call npm install
    if errorlevel 1 goto :fail
)

echo.
echo FreshrFridge web: http://localhost:5173
echo Also reachable on your LAN (WiFi) — use the Network URL Vite prints below.
echo Start START-BACKEND.bat in another window for AI + database.
echo.
npm run dev
goto :done

:fail
echo Web app failed to start.
:done
pause
endlocal
