Image optimization + og:image fix for the zhuazhou case (11 files)
======================================================================

Two things fixed:

1. WEBP CONVERSION: the 9 photos you uploaded for the zhuazhou case
   were raw Facebook .jpg exports, larger than the site's usual .webp
   images (site average ~125KB, these averaged ~166KB). Converted all
   9 to .webp at quality 75, checked visually for artifacts (none
   visible) - total size dropped from 1498KB to 992KB, a 34% reduction.
   This is a straight win for page load speed with no visible quality
   loss.

2. og:image bug I missed: case-baby-zhuazhou.html's og:image was still
   set to the generic logo.webp - because that page was generated from
   a template that defaults to logo.webp, and I'd only patched the
   *other* 18 pages' og:image in an earlier batch, not this one built
   afterward. Now points to the page's own hero photo.

THIS BATCH REQUIRES A DELETE STEP - the old .jpg files need to be
removed since Expand-Archive -Force only adds/overwrites, it doesn't
delete files that aren't in the zip.

Deploy steps (PowerShell) - run in this exact order:

  cd "C:\Users\user\Desktop\2345-main-with-videos"

  # 1. Extract the new webp images + updated html
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-webp-optimize.zip" -DestinationPath "." -Force

  # 2. Delete the now-unused original jpg files
  Remove-Item "assets\images\主廚抓周宴現場備料帆立貝.jpg"
  Remove-Item "assets\images\主廚抓周宴鐵板燒現場料理.jpg"
  Remove-Item "assets\images\抓周宴寶寶周歲蛋糕.jpg"
  Remove-Item "assets\images\抓周宴鐵板燒小羊排.jpg"
  Remove-Item "assets\images\抓周宴鐵板燒帆立貝鮭魚卵.jpg"
  Remove-Item "assets\images\抓周宴鐵板燒野生鱸魚擺盤.jpg"
  Remove-Item "assets\images\抓周宴鐵板燒鮑魚魚子醬.jpg"
  Remove-Item "assets\images\豪宅抓周宴圓桌佈置.jpg"
  Remove-Item "assets\images\豪宅鐵板吧檯實境.jpg"

  # 3. Check status - should show 2 modified (case-baby-zhuazhou.html,
  #    index.html), 9 deleted (the .jpg files), 9 new (the .webp files)
  git status

  git add -A
  git commit -m "抓周宴9張照片轉webp優化,並修正og:image"
  git push

IMPORTANT: use "git add -A" (not just "git add .") this time - it's
needed to correctly stage the deleted .jpg files along with the new
.webp files and modified html.
