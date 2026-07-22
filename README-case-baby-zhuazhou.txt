New case: 豪宅寶寶抓周到府鐵板燒 (2026-07-21)
================================================

This zip adds 1 new case page + 9 new photos, and updates 4 existing
pages to link it in (so it's not an orphan page).

New files:
- case-baby-zhuazhou.html (the new case page)
- assets/images/ - 9 new photos (renamed with descriptive Chinese
  filenames), copied from what you uploaded

Modified files (just added links to the new case, nothing else
changed):
- service-structure.html (site-wide sitemap listing)
- family-banquet-cases.html (family banquet case list)
- index.html (homepage case cards - added a 3rd card)
- sitemap.xml (added the new URL with lastmod/priority)

The page follows the same format/schema as your other 18 case pages
(Article schema, breadcrumb, full datetime with timezone, author url,
og:image set to a real photo from the case). Content was rewritten
from your Facebook post into the site's more formal editorial tone,
keeping the real details (community's built-in teppanyaki setup,
premium steel grade, staff cooperation, live-cooking menu items).

IMPORTANT - this zip has a subfolder structure (assets/images/), so
when extracting, make sure the images land in the right place:

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-case-baby-zhuazhou.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "新增案例:豪宅寶寶抓周到府鐵板燒(2026-07-21)"
  git push

git status should show 1 new case html file, 9 new image files, and
4 modified files (service-structure.html, family-banquet-cases.html,
index.html, sitemap.xml).
