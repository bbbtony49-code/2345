SHUYUAN Website Update - Footer Redesign + Homepage Fix
==========================================================

IMPORTANT: This package fixes a mistake from the previous batch - the
homepage's brand story section had reverted back to the old version.
This package corrects that AND adds the new footer redesign.

What's in this package:
- All HTML pages (root + blog/) - footer redesigned with brand
  manifesto, credential badges, and a "Popular Searches" keyword
  link section for extra internal linking (root pages only, not blog)
- index.html - homepage now correctly has BOTH the brand story section
  AND the new footer
- css/style.css - includes all styling for hero, footer, lang switch
- en/index.html - English homepage with matching footer update
- deploy.ps1 - PowerShell deploy script

How to use (PowerShell):
1. Unzip this package
2. Copy ALL extracted files/folders into your repo folder, overwriting
   files with the same name
3. Open PowerShell, cd into your repo folder
4. Run:
     .\deploy.ps1
5. Confirm when asked (y), and it will git add / commit / push automatically

Note: blog/ pages use a simpler footer template and were not included
in the footer redesign this round - can be done separately if wanted.
