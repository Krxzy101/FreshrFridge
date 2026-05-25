@echo off
REM Open backend + web in two windows
start "FreshrFridge Backend" cmd /k "%~dp0START-BACKEND.bat"
timeout /t 2 /nobreak >nul
start "FreshrFridge Web" cmd /k "%~dp0START-WEB.bat"
echo Started backend and web in separate windows.
echo Open http://localhost:5173 when Vite is ready.
