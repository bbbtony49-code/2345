全站健檢修正 — 套用方式

本次修正檔案共 16 個：
1. sitemap.xml                  → 補上 chef-credentials.html 條目
2. en/index.html                → 縮短過長的 title 標籤
3. 其餘 14 個頁面                → 補齊/精簡 meta description（原本 6-10字太短，或163字超長）
   corporate-catering-menu.html / private-chef-price.html / taipei-private-chef.html
   areas-yilan.html / private-chef-faq.html / menu-30.html / areas-taoyuan.html
   areas-hsinchu.html / areas-newtaipei.html / areas-taichung.html
   corporate-catering-price.html / yearend-catering.html / areas-taipei.html
   private-chef-menu.html / areas-miaoli.html

【操作方式：PowerShell，在 repo 根目錄執行】

Expand-Archive -Path "$env:USERPROFILE\Downloads\seo-fixes.zip" -DestinationPath "$env:USERPROFILE\Downloads\seo-fixes" -Force
Copy-Item "$env:USERPROFILE\Downloads\seo-fixes\delivery2\*" "." -Recurse -Force
git add sitemap.xml en/index.html corporate-catering-menu.html private-chef-price.html taipei-private-chef.html areas-yilan.html private-chef-faq.html menu-30.html areas-taoyuan.html areas-hsinchu.html areas-newtaipei.html areas-taichung.html corporate-catering-price.html yearend-catering.html areas-taipei.html private-chef-menu.html areas-miaoli.html
git commit -m "SEO修正：補齊meta description、修正過長title、sitemap補入新頁面"
git push
