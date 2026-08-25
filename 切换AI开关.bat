@echo off
chcp 65001 >nul
cd /d D:\Software\EditingTools\Programming\MyProtects\TrendRadar
set PYTHONPATH=
set CODEBUDDY_SAFE_DELETE_SANDBOX=0
"C:\Users\65290\AppData\Local\uv\uv.exe" run python scripts\toggle_ai.py
pause
