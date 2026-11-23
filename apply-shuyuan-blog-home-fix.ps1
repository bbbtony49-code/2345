$ErrorActionPreference = 'Stop'

$repo = (Get-Location).Path
$patch = Join-Path $repo 'shuyuan-blog-home-fix.patch'

if (-not (Test-Path (Join-Path $repo '.git'))) {
    throw "目前資料夾不是 Git repository：$repo"
}

if (-not (Test-Path $patch)) {
    throw "找不到 patch 檔案：$patch。請先把 shuyuan-blog-home-fix.patch 放到 repo 根目錄。"
}

$dirty = git status --porcelain -- blog/index.html
if ($dirty) {
    throw "blog/index.html 已有尚未提交的修改。請先備份、提交或暫存該檔案，再重新執行。"
}

git apply --check $patch
git apply $patch
git diff --check

Write-Host ''
Write-Host '已套用部落格首頁 SEO 修正：' -ForegroundColor Green
Write-Host '- blog/index.html 加入 robots: index, follow'
Write-Host '- JSON-LD WebPage / FAQPage URL 統一為 https://shuyuan-chef.com/blog/'
Write-Host ''
Write-Host '請檢查差異：' -ForegroundColor Cyan
Write-Host 'git diff -- blog/index.html'
Write-Host ''
Write-Host '確認無誤後再提交：' -ForegroundColor Cyan
Write-Host 'git add blog/index.html'
Write-Host 'git commit -m "SEO: unify blog homepage canonical URL"'
Write-Host 'git push origin main'
