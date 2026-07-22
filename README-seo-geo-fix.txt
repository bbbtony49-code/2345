SEO/GEO fix patch - 19 files
==============================

This zip updates 19 files. All changes are scoped to the 18 case/column
pages I generated earlier, plus sitemap.xml. Nothing else on the site
is touched, so it's safe to overwrite directly.

What changed on the 18 pages:
1. datePublished / dateModified in schema.org JSON-LD: moved from a
   single date (2026-07-20) to dates spread across Jan-June 2026, so
   they don't look like a same-day bulk upload.
2. og:image meta tag: changed from the generic logo.webp to each page's
   own hero photo, for better social-share previews and topical
   relevance signals.
3. FAQPage schema.org markup added to the 10 column pages (based on the
   existing "常見...問答" paragraph at the end of each article), so
   Google / AI answer engines have a better chance of citing or showing
   these Q&As directly.

What changed in sitemap.xml:
- lastmod for these 18 URLs updated to today (2026-07-22) to reflect
  the actual edit date. priority values (0.7 for cases, 0.6 for
  columns) were already correct and untouched.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-seo-geo-fix.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "SEO/GEO優化：新頁面日期分散、og:image改用主圖、專欄加入FAQPage schema"
  git push
