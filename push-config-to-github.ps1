#Requires -Version 5.1
# ===============================================================
#  TrendRadar 配置安全上传脚本
#  作用：把本地 config 目录上传到 GitHub Actions 仓库
#        同时自动清空敏感信息（webhook_url），避免泄露
#        并把运行频率改为每 30 分钟一次
#  作者：WorkBuddy
# ===============================================================

$ErrorActionPreference = "Stop"

# ---- 检查是否安装了 git ----
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "错误：本机没有安装 git，请先安装 git（https://git-scm.com/download/win）" -ForegroundColor Red
    pause
    exit 1
}

# ---- 输入 GitHub 信息 ----
$username = Read-Host "请输入你的 GitHub 用户名"
if ([string]::IsNullOrWhiteSpace($username)) {
    Write-Host "用户名不能为空" -ForegroundColor Red
    pause
    exit 1
}

$repo = Read-Host "请输入仓库名（直接回车使用默认 my-trendradar）"
if ([string]::IsNullOrWhiteSpace($repo)) { $repo = "my-trendradar" }

$localProject = "D:\Software\EditingTools\Programming\MyProtects\TrendRadar"
$tempDir = "$env:TEMP\trendradar-config-upload-$(Get-Random)"
$repoUrl = "https://github.com/$username/$repo.git"

Write-Host ""
Write-Host "将要上传本地配置到仓库：$repoUrl" -ForegroundColor Cyan
Write-Host "临时克隆目录：$tempDir" -ForegroundColor Gray
Write-Host ""

# ---- 克隆仓库 ----
Write-Host "步骤 1/5：正在克隆 GitHub 仓库..." -ForegroundColor Yellow
git clone $repoUrl $tempDir
if ($LASTEXITCODE -ne 0) {
    Write-Host "克隆失败，请检查：1) 仓库名是否正确 2) 仓库是否已创建 3) 是否已登录 git" -ForegroundColor Red
    pause
    exit 1
}

# ---- 复制本地 config 覆盖仓库 config ----
Write-Host "步骤 2/5：正在复制本地配置..." -ForegroundColor Yellow
$sourceConfig = Join-Path $localProject "config"
$targetConfig = Join-Path $tempDir "config"
if (Test-Path $targetConfig) {
    Remove-Item -Recurse -Force $targetConfig
}
Copy-Item -Recurse -Force $sourceConfig $targetConfig

# ---- 安全处理：清空 config.yaml 里的 feishu webhook_url ----
Write-Host "步骤 3/5：正在清除敏感信息（webhook_url）..." -ForegroundColor Yellow
$configYaml = Join-Path $targetConfig "config.yaml"
if (Test-Path $configYaml) {
    $content = Get-Content $configYaml -Raw -Encoding UTF8
    # 把 feishu webhook_url 的真实 URL 替换成空字符串，保留注释
    $content = $content -replace '(webhook_url:\s*)"[^"]*"(\s*# 飞书群机器人 webhook URL)', '$1""$2'
    Set-Content -Path $configYaml -Value $content -Encoding UTF8 -NoNewline
    Write-Host "已清空 feishu webhook_url（真实值保留在 GitHub Secrets 中）" -ForegroundColor Green
} else {
    Write-Host "警告：未找到 config.yaml" -ForegroundColor Yellow
}

# ---- 修改 cron 为每 30 分钟 ----
Write-Host "步骤 4/5：正在修改运行频率为每 30 分钟..." -ForegroundColor Yellow
$crawlerYml = Join-Path $tempDir ".github\workflows\crawler.yml"
if (Test-Path $crawlerYml) {
    $content = Get-Content $crawlerYml -Raw -Encoding UTF8
    # 匹配 - cron: "..." 这种格式，改成每 30 分钟
    $content = $content -replace '- cron:\s*"[^"]+"', '- cron: "*/30 * * * *"'
    Set-Content -Path $crawlerYml -Value $content -Encoding UTF8 -NoNewline
    Write-Host "已修改 cron 为：*/30 * * * *（每 30 分钟运行一次）" -ForegroundColor Green
} else {
    Write-Host "警告：未找到 .github/workflows/crawler.yml" -ForegroundColor Yellow
}

# ---- 提交并推送 ----
Write-Host "步骤 5/5：正在提交到 GitHub..." -ForegroundColor Yellow
Set-Location $tempDir

# 配置 git 用户名邮箱（如果还没配）
$gitName = git config user.name
$gitEmail = git config user.email
if ([string]::IsNullOrWhiteSpace($gitName)) { git config user.name "TrendRadar User" }
if ([string]::IsNullOrWhiteSpace($gitEmail)) { git config user.email "trendradar@local" }

git add .
git commit -m "Update config from local setup (safe: webhook cleared, cron */30)"
git push

if ($LASTEXITCODE -ne 0) {
    Write-Host "推送失败，请检查 git 登录状态" -ForegroundColor Red
    pause
    exit 1
}

# ---- 清理 ----
Set-Location $env:TEMP
Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "✅ 完成！配置已安全上传到 GitHub。" -ForegroundColor Green
Write-Host "现在请去 GitHub 仓库的 Actions 页面，手动运行一次 Get Hot News 测试。" -ForegroundColor Cyan
pause
