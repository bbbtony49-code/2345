Homepage case cards fix - 1 file (index.html)
================================================

Two issues fixed:

1. NO CLICKABLE LINK: every case card on the homepage (including the
   original 4, not just the 3 I added) was a plain <div>, never wrapped
   in an <a> tag - so there was no way to click through to the actual
   case page. Checked the CSS: .case-card already has "display: block"
   and the site's global "a" style already removes underline/color
   changes, meaning the cards were clearly DESIGNED to be links, just
   never wrapped. Fixed by wrapping each card in <a href="...">.

2. WRONG ORDER: cards were in insertion order, not date order, so a
   June case was displayed above July ones. Reordered all 7 cards by
   actual publish date (newest first) and corrected the visible date
   badges to match:

   1. 豪宅寶寶抓周到府鐵板燒 - 2026/07 (2026-07-21)
   2. 董事長宴請 - 2026/07 (2026-07-08) -> links to case-ceo-dinner.html
   3. 遊艇餐宴 - 2026/07 (2026-07-08) -> links to case-yacht.html
   4. 企業品牌活動 - 2026/07 (2026-07-08) -> links to case-opening.html
   5. 頂級和牛饗宴 - 2026/07 (2026-07-08) -> links to column-beef.html
   6. 雙層巴士移動餐宴 - 2026/06 (2026-06-18)
   7. 苗栗莊園戶外私廚 - 2026/05 (2026-05-22)

   Note: the first 4 original cards (董事長宴請/遊艇餐宴/頂級和牛饗宴/
   企業品牌活動) didn't have an obvious 1:1 matching case-*.html page
   by tag text alone - I matched them by cross-checking which page
   actually uses that same photo, then verified the page's own
   datePublished for correct sort order.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-homepage-cards-fix.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "首頁案例卡片補上可點擊連結,並依實際日期重新排序"
  git push

git status should show ONLY index.html as modified - nothing else,
nothing deleted.
