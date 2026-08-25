#Requires -Version 5.1
# ===============================================================
#  TrendRadar 整库上传到 GitHub（双击 upload-full-project.bat 运行）
#  作用：把整个本地项目（含你的 43 平台 + 8 RSS 配置）推到你的 GitHub 仓库
#        自动脱敏 webhook、写 .gitignore、改 remote、提交、推送
#  作者：WorkBuddy
# ===============================================================
$ErrorActionPreference = "Stop"
$proj = "D:\Software\EditingTools\Programming\MyProtects\TrendRadar"

# ---- 检查 git ----
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "错误：本机未安装 git，请先装 https://git-scm.com/download/win" -ForegroundColor Red
    pause; exit 1
}

# ---- 输入 GitHub 信息 ----
$username = Read-Host "请输入你的 GitHub 用户名"
if ([string]::IsNullOrWhiteSpace($username)) { Write-Host "用户名不能为空"; pause; exit 1 }

$repo = Read-Host "请输入仓库名（直接回车=my-trendradar）"
if ([string]::IsNullOrWhiteSpace($repo)) { $repo = "my-trendradar" }
$repoUrl = "https://github.com/$username/$repo.git"

Set-Location $proj

# ---- 步骤1：脱敏（清空所有 webhook_url 明文，真实值走 GitHub Secrets） ----
Write-Host "步骤1/5：脱敏 config.yaml 中的 webhook_url..." -ForegroundColor Yellow
$cfg = "config/config.yaml"
$c = Get-Content $cfg -Raw -Encoding UTF8
$c = $c -replace '(webhook_url:\s*")[^"]*(")', '$1"$2'
Set-Content -Path $cfg -Value $c -Encoding UTF8 -NoNewline
Write-Host "  已清空（真实飞书地址保留在 GitHub Secrets）" -ForegroundColor Green

# ---- 步骤2：写 .gitignore（排除缓存和产物，避免泄露/体积过大） ----
Write-Host "步骤2/5：写入 .gitignore..." -ForegroundColor Yellow
@"
__pycache__/
*.pyc
output/
Feishu
.venv/
*.db
"@ | Set-Content -Path ".gitignore" -Encoding UTF8
Write-Host "  已排除 __pycache__ / output / *.db" -ForegroundColor Green

# ---- 步骤3：改 remote 指向你的仓库 ----
Write-Host "步骤3/5：设置 git remote -> $repoUrl" -ForegroundColor Yellow
git remote set-url origin $repoUrl 2>$null
if ($LASTEXITCODE -ne 0) { git remote add origin $repoUrl }
git remote -v

# ---- 步骤4：提交 ----
Write-Host "步骤4/5：提交所有文件..." -ForegroundColor Yellow
git add -A
git commit -m "TrendRadar 完整项目：43平台+8RSS+AI已配+本地可视化编辑器"
if ($LASTEXITCODE -ne 0) { Write-Host "  （无新变更或提交跳过）" -ForegroundColor Gray }

# ---- 步骤5：推送（--force 覆盖模板默认提交，因为历史不同） ----
Write-Host "步骤5/5：推送到 GitHub（强制覆盖模板默认文件）..." -ForegroundColor Yellow
# 一次性记住凭据，之后推送不再反复输 PAT
git config --global credential.helper store
git branch -M main
git push --force -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ 推送失败，常见原因：" -ForegroundColor Red
    Write-Host "  1) git 未登录：请先运行 'gh auth login' 或用 PAT 当密码" -ForegroundColor Red
    Write-Host "  2) 仓库不存在：请先去 GitHub 建好空仓库 $repo" -ForegroundColor Red
    Write-Host "  3) 仓库非空冲突：建仓库时不要勾选 README/.gitignore，或先 git pull" -ForegroundColor Red
    pause; exit 1
}

Write-Host ""
Write-Host "✅ 上传完成！下一步去 GitHub 仓库加 Secrets：" -ForegroundColor Green
Write-Host "  Settings -> Secrets and variables -> Actions -> New repository secret" -ForegroundColor Cyan
Write-Host "  FEISHU_WEBHOOK_URL = https://open.feishu.cn/open-apis/bot/v2/hook/7516a809-8cfa-4c6b-a604-3e9dc084f3dc" -ForegroundColor White
Write-Host "  AI_API_KEY          = sk-91043019b6004b9ba602ca2960175b74" -ForegroundColor White
Write-Host "  AI_MODEL            = deepseek/deepseek-chat" -ForegroundColor White
Write-Host "  AI_ANALYSIS_ENABLED = true" -ForegroundColor White
Write-Host "  AI_TRANSLATION_ENABLED = true" -ForegroundColor White
Write-Host "  然后 Actions 页 -> Get Hot News -> Run workflow 测试" -ForegroundColor Cyan
pause
