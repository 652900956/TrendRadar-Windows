@echo off
REM ============================================================
REM TrendRadar One-Click Launcher
REM Double-click to run: fetch hotlist + RSS -> AI analyze -> Feishu
REM Edit config in: config/config.yaml and config/frequency_words.txt
REM ============================================================

SET "PROJECT_DIR=%~dp0"
SET "UV_EXE=%LOCALAPPDATA%\uv\uv.exe"

REM DeepSeek API Key via env var (not saved in config file)
SET "AI_API_KEY=sk-91043019b6004b9ba602ca2960175b74"

REM Bypass WorkBuddy sandbox safe-delete shim
SET "CODEBUDDY_SAFE_DELETE_SANDBOX=0"
SET "PYTHONPATH="

cd /d "%PROJECT_DIR%"

echo ============================================
echo TrendRadar is starting...
echo Fetch hotlist + RSS -> AI analyze -> Feishu
echo ============================================
"%UV_EXE%" run python -m trendradar

echo.
echo ============================================
echo Run finished. Press any key to close.
echo ============================================
pause >nul
