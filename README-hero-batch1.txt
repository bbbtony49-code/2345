Hero image fix - batch 1 of 3 (19 pages)
===========================================

These 19 pages had their main visual (page-hero-bg) AND og:image both
set to the generic logo.webp, so visitors were seeing a stretched
brand logo instead of a real photo when opening the page.

For each page, I found a real photo already referenced elsewhere in
the SAME page's body content that is topically correct AND not a
shared template filler image (checked site-wide usage count so I
didn't accidentally pick a generic stock image used on 30+ pages).
That photo is now used for both the hero background and og:image.

Pages fixed in this batch:
- case-press.html, case-ceo-dinner.html, case-opening.html,
  case-brand-wine.html, case-proposal.html, case-yacht.html,
  case-medical-banquet.html, case-chairman-longevity.html,
  case-tech-yearend.html, case-family-dinner.html,
  case-luxury-birthday.html, case-construction-banquet.html,
  case-more.html
- areas-yilan.html
- chef-award.html, chef-experience.html, chef-team.html
- family-banquet-luxury.html
- corporate-catering-vvip.html

Note: this is batch 1 of 3. There are 23 more pages with the same
generic-logo hero problem, but they don't have a unique photo already
referenced in their body content (their body content uses shared
template filler images too) - those need photos sourced from the
wider image library instead, which I'll send as batch 2.

Deploy steps (PowerShell):

  cd "C:\Users\user\Desktop\2345-main-with-videos"
  Expand-Archive -LiteralPath "C:\Users\user\Downloads\2345-hero-images-batch1.zip" -DestinationPath "." -Force
  git status
  git add .
  git commit -m "修正19個頁面主視覺誤用logo問題,改為對應真實案例照片"
  git push
