FAQPage schema for all remaining 32 columns
=============================================

This completes FAQPage structured data across all 42 column articles
on the site (the other 10 already had it from the previous patch).

26 of these 32 pages already had a "常見...問答" style closing
paragraph in the article body - I converted that existing content into
clean Question/Answer pairs in the schema (no new claims added, just
restructured what was already written).

The remaining 6 are the "主廚故事" narrative columns
(column-story-award, column-story-each-dish, column-story-first-dinner,
column-story-life, column-story-market, column-story-why-private),
which didn't have an explicit Q&A section. For these I wrote 2 natural
questions per article based on what the article itself already says,
so the FAQ content stays grounded in the existing text.

All 32 files validated: correct JSON-LD syntax, no broken HTML
structure, FAQPage schema confirmed present in all 32.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-faq-all-columns.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "全站42篇專欄補齊FAQPage結構化資料"
  git push
