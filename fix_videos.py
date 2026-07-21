#!/usr/bin/env python3
import os, re, subprocess, glob

ROOT = "/home/claude/2345"
os.chdir(ROOT)

# 1) Filename mapping (Chinese -> ASCII slug), applies to both videos/*.mp4 and video-posters/*.jpg
NAME_MAP = {
    "上湯砂鍋大排翅料理實錄": "shark-fin-soup-casserole",
    "主廚中西式飯店實境專業度呈現": "chef-hotel-style-fusion",
    "主廚團隊出餐實錄": "chef-team-service-record",
    "主廚團隊出餐影片1": "chef-team-plating-1",
    "主廚團隊遊艇實錄超經典": "chef-team-yacht-classic",
    "主廚團隊飯店實錄": "chef-team-hotel-record",
    "主廚淋醬汁收尾上菜很可以": "chef-sauce-finishing",
    "主廚綜藝大熱門節目及料理影片也很可以放": "chef-variety-show-clip",
    "主廚西式料理實境專業度呈現": "chef-western-cuisine-showcase",
    "台中七期豪宅董座生日宴": "taichung-mansion-birthday",
    "台北豪宅vip餐宴實錄": "taipei-mansion-vip-banquet",
    "天母生日宴客": "tianmu-birthday-banquet",
    "客戶餐點實錄": "client-dining-record",
    "客戶餐點體驗實錄": "client-dining-experience",
    "百人自助式餐點實錄": "hundred-guest-buffet",
    "私廚團隊辦桌活動實境": "private-chef-banquet-event",
    "私廚團隊飯店實錄": "private-chef-hotel-record",
    "私廚百人餐宴尾牙春酒團隊現場buffet料理製作": "private-chef-yearend-buffet",
    "私廚精緻下午茶現場製作非常美又衛生": "private-chef-afternoon-tea",
    "私廚聖誕節百人buffet現場製作": "private-chef-christmas-buffet",
    "秋季大閘蟹料理": "autumn-hairy-crab",
    "精緻西餐前菜實境": "western-appetizer-showcase",
    "精緻西餐和牛": "wagyu-western-course",
    "美味生蠔料裡": "fresh-oyster-dish",
    "苗栗四天四夜私廚外燴": "miaoli-4day-catering",
    "董事長宴請貴賓餐宴": "chairman-vip-banquet",
    "遊艇出餐風景": "yacht-dining-scenery",
    "飯店餐點實錄": "hotel-dining-record",
    "餐宴餐桌布置": "banquet-table-setting",
    "鮮活嚴選海鮮在這": "fresh-seafood-selection",
}

# 2) Rename video files
renamed = []
for old_zh, new_en in NAME_MAP.items():
    old_path = f"assets/videos/{old_zh}.mp4"
    new_path = f"assets/videos/{new_en}.mp4"
    if os.path.exists(old_path):
        subprocess.run(["git", "mv", old_path, new_path], check=True)
        renamed.append((old_path, new_path))
    old_thumb = f"assets/images/video-posters/{old_zh}.jpg"
    new_thumb = f"assets/images/video-posters/{new_en}.jpg"
    if os.path.exists(old_thumb):
        subprocess.run(["git", "mv", old_thumb, new_thumb], check=True)
        renamed.append((old_thumb, new_thumb))

print(f"Renamed {len(renamed)} files")

# 3) Update references across all html + xml files
target_files = glob.glob("**/*.html", recursive=True) + ["video-sitemap.xml"]
target_files = [f for f in target_files if ".git" not in f]

total_replacements = 0
for f in target_files:
    with open(f, encoding="utf-8") as fh:
        content = fh.read()
    original = content

    # Replace old Chinese filenames with new ascii ones (mp4 and jpg references)
    for old_zh, new_en in NAME_MAP.items():
        content = content.replace(f"{old_zh}.mp4", f"{new_en}.mp4")
        content = content.replace(f"{old_zh}.jpg", f"{new_en}.jpg")

    # Fix broken thumbnail extension bugs
    content = content.replace("video-poster-kitchen.jpg", "video-poster-kitchen.webp")
    content = content.replace("video-poster-banquet.jpg", "video-poster-banquet.webp")

    # Fix preload="none" -> preload="metadata" on <video> tags
    content = re.sub(r'(<video\b[^>]*?)preload="none"', r'\1preload="metadata"', content)

    if content != original:
        with open(f, "w", encoding="utf-8") as fh:
            fh.write(content)
        total_replacements += 1

print(f"Updated references in {total_replacements} files")
