# 一次跑完全部 5 支影片排版修復腳本
# 請把這個資料夾解壓縮後，整批放到你的 repo 根目錄（跟 chef.html 同一層）再執行這支
.\fix-chef.ps1
.\fix-ingredients.ps1
.\fix-corporate-catering-tailend.ps1
.\fix-vip-banquet-yacht.ps1
.\fix-video-section-padding.ps1

Write-Host ""
Write-Host "全部跑完，請手動確認每一行有沒有紅字失敗訊息。" -ForegroundColor Yellow
