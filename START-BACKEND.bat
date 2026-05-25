@echo off
REM Start Groq AI + SQLite database server (port 3000)
setlocal
set "GROQ_DIR=%~dp0..\Groq"

if not exist "%GROQ_DIR%\server.js" (
    echo ERROR: Backend not found at %GROQ_DIR%
    pause
    exit /b 1
)

if not exist "%GROQ_DIR%\.env" (
    echo.
    echo  Create %GROQ_DIR%\.env first:
    echo    copy .env.example .env
    echo    Edit .env and set GROQ_API_KEY=your_key
    echo.
    pause
    exit /b 1
)

cd /d "%GROQ_DIR%"
if not exist "node_modules" (
    echo Installing backend dependencies...
    call npm install
    if errorlevel 1 goto :fail
)

echo Starting backend on http://localhost:3000 ...
echo Database: freshrfridge.db in Groq folder
echo.
npm start
goto :done

:fail
echo Backend failed to start.
:done
pause
endlocal
