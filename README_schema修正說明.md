# Schema 修正說明

這個 ZIP **只包含被修改過的 65 個檔案**（不含未變動的圖片、影片、其他 200 個頁面），
方便你直接覆蓋貼到現有專案裡，不用重新上傳整個 434MB 的網站。

## 修改內容總覽

| 修改類型 | 檔案數 | 說明 |
|---|---|---|
| 補上基礎 WebPage + BreadcrumbList | 44 | 原本完全沒有任何 Schema 的頁面（pricing/menu/ingredients/areas/private-chef 子頁等） |
| 其中額外加 Service Schema | 6 | pricing-*、menu-*、private-chef-price/menu、corporate-catering-price/menu |
| 新增 VideoObject | 18 | 站上原本就有 `<video>` 影片的頁面，抓取真實 poster 圖與 mp4 檔名建立 |
| 新增 HowTo | 2 | private-chef-process.html（5步驟）、corporate-catering-process.html（4步驟），步驟文字直接取自頁面上原有的流程說明文字 |
| LocalBusiness 加註 FoodEstablishment | 1 | index.html，改為 `"@type": ["LocalBusiness","FoodEstablishment"]` |

全部 260 個 JSON-LD 區塊已用 Python 逐一 `json.loads()` 驗證過，語法都正確。

## ⚠️ 上線前必須手動確認一件事

**VideoObject 的 `uploadDate` 目前是佔位日期 `2025-06-01`**，這是我無法從檔案中得知真實上傳日期，
所以先放一個合理的暫定值。Google 對 VideoObject 的 rich result **要求真實的 uploadDate**，
建議你上線前依照每支影片實際拍攝／上傳的時間手動修改，涉及檔案如下：

```
private-chef.html, family-banquet-birthday.html, vip-banquet-yacht.html,
corporate-catering-afternoontea.html, portfolio-banquet.html, vip-banquet-chairman.html,
private-chef-taipei.html, ingredients.html, portfolio-western.html, portfolio.html,
chef-media.html, corporate-catering-tailend.html, areas-miaoli.html,
private-chef-taichung.html, portfolio-corporate.html, chef.html,
private-chef-newtaipei.html, chef-philosophy.html
```

## 沒有動的部分

- 原本已有 Schema 的 223 個頁面，**完全沒有更動**，避免破壞既有正確的標記。
- `HowTo` 只加在真的有明確步驟文字的 2 個流程頁，沒有在缺乏步驟內容的頁面硬塞假資料。
- 沒有新增 `FoodEstablishment` 到全站每一頁，只在首頁的 LocalBusiness 上加註，避免重複宣告造成混淆。

## Windows PowerShell 上傳步驟

1. 把這個 ZIP 存到你原本告訴我的路徑：
   `C:\Users\user\Desktop\2345-main-with-videos.zip`

2. 解壓縮到暫存資料夾：
   ```powershell
   Expand-Archive -Path "C:\Users\user\Desktop\2345-main-with-videos.zip" -DestinationPath "C:\Users\user\Desktop\schema-fix-temp" -Force
   ```

3. 把解壓出來的檔案複製覆蓋到你原本的網站專案資料夾（假設你的網站 repo 在 `C:\Users\user\Desktop\2345`）：
   ```powershell
   Copy-Item -Path "C:\Users\user\Desktop\schema-fix-temp\2345-main-with-videos\*" -Destination "C:\Users\user\Desktop\2345" -Recurse -Force
   ```

4. 進到你的 repo 資料夾，用 git 檢查改了哪些檔案、上傳：
   ```powershell
   cd C:\Users\user\Desktop\2345
   git status
   git add .
   git commit -m "補齊 Schema: WebPage/BreadcrumbList/Service/VideoObject/HowTo/FoodEstablishment"
   git push
   ```

5. 上線後用 Google 的 [Rich Results Test](https://search.google.com/test/rich-results) 抽測幾頁，
   特別是有 VideoObject 的頁面（確認 uploadDate 已改成真實日期）。
