Hero image fix - batch 2 of 3 (23 pages, FINAL batch for the 42-page issue)
==============================================================================

These 23 pages also had page-hero-bg AND og:image set to the generic
logo.webp. Unlike batch 1, these pages didn't have a unique photo
already referenced in their own body content (their body used shared
template filler images), so I sourced a topically-matched photo for
each from the wider image library (checked usage count to avoid
picking another over-used generic image).

Highlights:
- chef-lin.html now uses chef-lin-portrait.webp - an actual portrait
  photo of the chef, which is about as good a match as it gets.
- areas-miaoli.html now uses 戶外苗栗服務實境團隊合照.webp - a
  Miaoli-specific team photo.
- The rest were matched by theme: birthday banquets get warm home/venue
  photos, corporate tea events get tea-service photos, process/pricing
  pages get team-service photos, etc.

Combined with batch 1 (19 pages), this completes all 42 pages that had
the generic-logo hero problem across the site.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-hero-images-batch2.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "修正剩餘23個頁面主視覺誤用logo問題,改為對應真實照片"
  git push
