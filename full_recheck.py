#!/usr/bin/env python3
import os, re, json
from bs4 import BeautifulSoup
from collections import defaultdict

ROOT = "."
files = []
for dirpath, dirnames, filenames in os.walk(ROOT):
    if "/.git" in dirpath: continue
    for fn in filenames:
        if fn.endswith(".html"):
            files.append(os.path.relpath(os.path.join(dirpath, fn), ROOT))
files = sorted(files)
print(f"總 HTML 頁面數: {len(files)}")

def normalize_link(from_rel, href):
    href = href.split("#")[0].split("?")[0]
    if href == "": return None
    if href.startswith("/"): return href.lstrip("/")
    base_dir = os.path.dirname(from_rel)
    return os.path.normpath(os.path.join(base_dir, href)).replace("\\", "/")

pages = {}
all_set = set(files)
incoming = defaultdict(set)
broken_links = []

for rel in files:
    content = open(rel, encoding="utf-8", errors="ignore").read()
    soup = BeautifulSoup(content, "lxml")
    is_redirect = bool(soup.find("meta", attrs={"http-equiv": re.compile("refresh", re.I)}))
    desc_tag = soup.find("meta", attrs={"name": "description"})
    desc = desc_tag["content"].strip() if desc_tag and desc_tag.get("content") else ""
    canonical = soup.find("link", attrs={"rel": "canonical"})
    h1s = soup.find_all("h1")
    ld_json = soup.find_all("script", attrs={"type": "application/ld+json"})
    schema_types = []
    for tag in ld_json:
        try:
            data = json.loads(tag.string or "{}")
            items = data if isinstance(data, list) else [data]
            for d in items:
                schema_types.append(d.get("@type", "?"))
        except Exception:
            schema_types.append("PARSE_ERROR")
    for tag in soup(["script", "style", "noscript"]): tag.decompose()
    text_len = len(soup.get_text(strip=True))

    links = set()
    for a in BeautifulSoup(content, "lxml").find_all("a", href=True):
        href = a["href"]
        if href.startswith(("mailto:", "tel:", "javascript:", "#")): continue
        if href.startswith("http") and "shuyuan-chef.com" not in href: continue
        links.add(href)

    pages[rel] = dict(is_redirect=is_redirect, desc=desc, canonical=bool(canonical),
                       h1_count=len(h1s), schema=schema_types, text_len=text_len)

    for href in links:
        norm = normalize_link(rel, href)
        if norm is None: continue
        if norm in all_set or os.path.exists(norm):
            incoming[norm].add(rel)
        else:
            broken_links.append((rel, href))

orphans = [f for f in files if f not in incoming]
thin = [(f, d["text_len"]) for f, d in pages.items() if not d["is_redirect"] and d["text_len"] < 800]
short_desc = [(f, len(d["desc"])) for f, d in pages.items() if not d["is_redirect"] and len(d["desc"]) < 50]
long_desc = [(f, len(d["desc"])) for f, d in pages.items() if not d["is_redirect"] and len(d["desc"]) > 160]
no_schema = [f for f, d in pages.items() if not d["is_redirect"] and not d["schema"]]
no_canonical = [f for f, d in pages.items() if not d["is_redirect"] and not d["canonical"]]
no_h1 = [f for f, d in pages.items() if not d["is_redirect"] and d["h1_count"] == 0]

print(f"\n孤兒頁: {len(orphans)}"); [print(" -", o) for o in orphans]
print(f"\n失效內部連結: {len(broken_links)}"); [print(" -", b) for b in broken_links[:30]]
print(f"\n薄內容頁面(<800字): {len(thin)}"); [print(" -", t) for t in thin[:30]]
print(f"\nmeta description太短(<50字): {len(short_desc)}"); [print(" -", s) for s in short_desc[:30]]
print(f"\nmeta description太長(>160字): {len(long_desc)}"); [print(" -", s) for s in long_desc]
print(f"\n缺少schema: {len(no_schema)}"); [print(" -", s) for s in no_schema[:20]]
print(f"\n缺少canonical: {len(no_canonical)}"); [print(" -", s) for s in no_canonical[:20]]
print(f"\n缺少H1: {len(no_h1)}"); [print(" -", s) for s in no_h1[:20]]

# sitemap check
sitemap = open("sitemap.xml", encoding="utf-8").read()
urls = re.findall(r"<loc>(.*?)</loc>", sitemap)
lastmods = re.findall(r"<lastmod>(.*?)</lastmod>", sitemap)
priorities = re.findall(r"<priority>(.*?)</priority>", sitemap)
print(f"\nsitemap網址數: {len(urls)} | lastmod數: {len(lastmods)} | priority數: {len(priorities)}")
site_paths = set((u.replace("https://shuyuan-chef.com/", "") or "index.html") for u in urls)
missing_from_sitemap = sorted(all_set - site_paths - set(f for f, d in pages.items() if d["is_redirect"]))
print(f"未進sitemap的正式頁面: {len(missing_from_sitemap)}"); [print(" -", m) for m in missing_from_sitemap]
extra_in_sitemap = sorted(site_paths - all_set)
print(f"sitemap裡但檔案不存在: {len(extra_in_sitemap)}"); [print(" -", e) for e in extra_in_sitemap]

# video checks
preload_none = []
for f in files:
    c = open(f, encoding="utf-8", errors="ignore").read()
    if 'preload="none"' in c:
        preload_none.append(f)
print(f"\npreload=none殘留: {len(preload_none)}"); [print(" -", p) for p in preload_none]

non_ascii_video = []
if os.path.exists("assets/videos"):
    for fn in os.listdir("assets/videos"):
        if re.search(r'[^\x00-\x7F]', fn):
            non_ascii_video.append(fn)
if os.path.exists("assets/images/video-posters"):
    for fn in os.listdir("assets/images/video-posters"):
        if re.search(r'[^\x00-\x7F]', fn):
            non_ascii_video.append(fn)
print(f"影片/縮圖中文檔名殘留: {len(non_ascii_video)}"); [print(" -", n) for n in non_ascii_video]

vs = open("video-sitemap.xml", encoding="utf-8").read()
vlocs = re.findall(r'<video:content_loc>https://shuyuan-chef\.com/(.*?)</video:content_loc>', vs)
vthumbs = re.findall(r'<video:thumbnail_loc>https://shuyuan-chef\.com/(.*?)</video:thumbnail_loc>', vs)
missing_video_files = [x for x in vlocs+vthumbs if not os.path.exists(x)]
print(f"video-sitemap指向但檔案遺失: {len(missing_video_files)}"); [print(" -", m) for m in missing_video_files]

# index.html specific checks
idx = open("index.html", encoding="utf-8").read()
print(f"\nindex.html - entrance動畫存在: {'siteEntrance' in idx}")
print(f"index.html - hreflang存在: {'hreflang' in idx}")
print(f"index.html - 評論區塊存在: {'reviews-section' in idx}")
print(f"index.html - trustindex殘留: {'trustindex' in idx}")
rc = re.search(r'"reviewCount": "(\d+)"', idx)
print(f"index.html - aggregateRating reviewCount: {rc.group(1) if rc else '找不到'}")

# redirect stub check
redirect_stubs = ["areas-hsinchu.html","areas-newtaipei.html","areas-taichung.html","areas-taipei.html","areas-taoyuan.html",
                   "corporate-catering-menu.html","corporate-catering-price.html","private-chef-faq.html",
                   "private-chef-menu.html","private-chef-price.html","taipei-private-chef.html","yearend-catering.html"]
missing_redirect_files = [f for f in redirect_stubs if not os.path.exists(f)]
print(f"\n轉址存根頁遺失: {len(missing_redirect_files)}"); [print(" -", m) for m in missing_redirect_files]
