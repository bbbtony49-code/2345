Rich Results non-critical fix - 18 files
==========================================

Fixes the 2 non-critical warnings Google's Rich Results Test flagged
on column-oyster.html (same pattern applies to all 18 pages):

1. datePublished / dateModified upgraded from date-only
   (e.g. "2026-04-02") to full ISO8601 with timezone
   (e.g. "2026-04-02T10:00:00+08:00").

2. author.url added, pointing to https://shuyuan-chef.com/chef.html

Both fields are optional per Google's spec, so this does not change
whether the pages are eligible for rich results (they already were) -
it just removes the two warnings.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-datetime-fix.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "修正結構化資料datetime格式與作者url欄位"
  git push

After pushing, wait a few minutes for GitHub Pages / CDN cache to
refresh, then re-run https://search.google.com/test/rich-results
on column-oyster.html to confirm 0 warnings.
