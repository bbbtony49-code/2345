og:image final fix - 59 files (completes all 101 pages)
===========================================================

This is the last batch of the og:image cleanup. These 59 pages already
had a correct, real photo as their main visual (page-hero-bg) - only
the og:image meta tag (used for LINE/Facebook link previews) was still
pointing to the generic logo.webp. I set og:image to match each page's
own existing hero photo, so the fix required no new image selection -
just syncing the two tags.

Combined with the earlier batches (18 new pages + 42 hero-image
batches 1&2), all 101 pages that originally had a generic-logo
og:image are now fixed. Site-wide check confirms 0 pages remaining
with og:image pointing to logo.webp.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-ogimage-final.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "全站59個頁面og:image改為對應各自主視覺圖,完成全站101頁修正"
  git push
