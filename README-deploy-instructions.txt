舒苑飲食文化網站 — 新增案例與主廚專欄 部署說明
================================================

這個壓縮檔包含 23 個檔案，全部都是「根目錄」層級的檔案，
解壓縮後直接覆蓋到你的專案資料夾即可（不需要建立子資料夾）。

【檔案內容】

新增的 8 個服務案例頁面：
- case-double-decker-bus.html   雙層巴士移動餐宴
- case-miaoli-manor.html        苗栗莊園戶外私廚
- case-textile-buffet.html      紡織集團百人自助餐
- case-celebrity-private.html   藝人團體私廚餐宴
- case-lunar-newyear.html       年節圍爐私廚
- case-xinyi-luxury.html        信義豪宅社區家宴
- case-finance-executive.html   金融銀行業高層宴請
- case-christmas-buffet.html    聖誕節百人自助餐

新增的 10 個主廚專欄頁面：
- column-oyster.html            生蠔
- column-abalone.html           鮑魚
- column-crab.html              帝王蟹與蟹類食材
- column-buffet-planning.html   大型自助餐規劃
- column-outdoor-catering.html  戶外私廚外燴
- column-mobile-banquet.html    移動式餐宴
- column-festive-menu.html      節慶主題菜單設計
- column-team-service.html      出餐團隊分工
- column-ingredient-eye.html    主廚選食材的眼光
- column-seasonal-menu.html     季節限定菜單

修改過的既有頁面（已加入上述新頁面的連結，避免變成孤兒頁）：
- service-structure.html        總服務導覽（完整 sitemap）
- index.html                    首頁（案例區塊新增 2 則案例卡片）
- corporate-catering-cases.html 企業外燴案例列表
- vip-banquet-cases.html        VIP 餐宴案例列表
- family-banquet-cases.html     家宴案例列表

【使用的圖片】
全部使用你 repo 裡 assets/images 資料夾中「原本沒有被任何頁面引用過」的
現成圖片，沒有新增或刪除任何圖片檔案，也已逐一確認路徑存在、尺寸正確。

================================================
在你的電腦上部署（PowerShell）
================================================

1. 打開 PowerShell，先切到你的專案資料夾：

   cd "C:\Users\user\Desktop\2345-main-with-videos"

2. 解壓縮下載的 zip（假設檔名是 2345-new-cases-and-columns.zip，
   且下載到「下載」資料夾，路徑請依實際狀況調整）：

   Expand-Archive -Path "$env:USERPROFILE\Downloads\2345-new-cases-and-columns.zip" -DestinationPath . -Force

   這個指令會把 23 個檔案直接解壓到目前目錄，並覆蓋掉 5 個同名的既有檔案
   （service-structure.html、index.html、corporate-catering-cases.html、
   vip-banquet-cases.html、family-banquet-cases.html）。

3. 確認檔案都已經在正確位置：

   Get-ChildItem case-double-decker-bus.html, column-oyster.html

4. 用 git 上傳到 GitHub：

   git add .
   git commit -m "新增 8 個服務案例與 10 個主廚專欄頁面"
   git push

如果你的預設分支不是 main，請把最後一行改成：
   git push origin <你的分支名稱>

================================================
建議之後可以做的事
================================================
- 到 GitHub Pages（或你使用的部署平台）確認網站更新後，
  隨機點開 2-3 個新頁面檢查圖片與排版是否正常顯示。
- 若要「定期更新網站」，可以之後再請我依同樣的方式，
  從 assets/images 剩餘的未使用圖片中，持續產出新一批案例與專欄頁面。
