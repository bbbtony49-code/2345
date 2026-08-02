# ============================================
# SHUYUAN 官網部署腳本
# 用法：把這個檔案跟 index.html / css / en 資料夾
# 都放進你的 repo 資料夾裡，然後在 PowerShell 執行：
#   .\deploy.ps1
# ============================================

# 1. 確認目前在 git repo 裡
if (-not (Test-Path ".git")) {
    Write-Host "❌ 這裡不是 git repo 根目錄，請先 cd 進你的 2345 專案資料夾再執行。" -ForegroundColor Red
    exit
}

# 2. 建立 en 資料夾（如果還沒有）
if (-not (Test-Path "en")) {
    New-Item -ItemType Directory -Path "en" | Out-Null
    Write-Host "✅ 已建立 en 資料夾" -ForegroundColor Green
}

# 3. 提示確認檔案是否已經覆蓋
Write-Host ""
Write-Host "請確認以下檔案已經放到正確位置：" -ForegroundColor Yellow
Write-Host "  - index.html        (repo 根目錄，中文首頁)"
Write-Host "  - css\style.css      (覆蓋原本的 css/style.css)"
Write-Host "  - en\index.html      (新的英文首頁)"
Write-Host ""
$confirm = Read-Host "檔案都放好了嗎？(y/n)"
if ($confirm -ne "y") {
    Write-Host "先把檔案複製進去再執行一次這個腳本。" -ForegroundColor Yellow
    exit
}

# 4. Git 加入變更
git add index.html css/style.css en/index.html

# 5. 顯示變更狀態讓你確認
Write-Host ""
Write-Host "以下是即將提交的變更：" -ForegroundColor Cyan
git status

# 6. 提交
$commitMsg = "首頁精品化改版：品牌敘事 + 中英語言切換"
git commit -m $commitMsg

# 7. 推送到 GitHub
Write-Host ""
Write-Host "準備推送到 GitHub main 分支..." -ForegroundColor Cyan
git push origin main

Write-Host ""
Write-Host "🎉 完成！幾分鐘後網站就會更新。" -ForegroundColor Green
