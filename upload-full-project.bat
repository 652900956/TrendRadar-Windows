@echo off
chcp 65001 >nul
echo ============================================
echo   TrendRadar 整库上传到 GitHub（双击运行）
echo ============================================
echo.
echo 本脚本会：脱敏 webhook -> 写.gitignore -> 改remote -> 提交 -> 推送
echo 运行前请确保：1) GitHub 已建好空仓库  2) git 已登录
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "D:\Software\EditingTools\Programming\MyProtects\TrendRadar\upload-full-project.ps1"
echo.
echo [脚本结束] 按任意键关闭窗口
pause >nul
