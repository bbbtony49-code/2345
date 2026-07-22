#!/usr/bin/env python3
from PIL import Image
import os, glob

ROOT = "assets/images"
MAX_DIM = 1600
WEBP_QUALITY = 75
JPG_QUALITY = 78
MIN_SIZE_TO_SKIP = 80 * 1024  # don't bother re-processing already-small files

results = []
total_before = 0
total_after = 0
skipped = []
errors = []

files = glob.glob(f"{ROOT}/**/*.webp", recursive=True) + \
        glob.glob(f"{ROOT}/**/*.jpg", recursive=True) + \
        glob.glob(f"{ROOT}/**/*.jpeg", recursive=True) + \
        glob.glob(f"{ROOT}/**/*.png", recursive=True)

for f in files:
    try:
        orig_size = os.path.getsize(f)
        if orig_size < MIN_SIZE_TO_SKIP:
            skipped.append(f)
            continue

        img = Image.open(f)
        fmt = img.format  # WEBP, JPEG, PNG
        w, h = img.size
        scale = min(1.0, MAX_DIM / max(w, h))
        new_size = (max(1, int(w * scale)), max(1, int(h * scale)))

        if scale < 1.0:
            img_out = img.convert("RGB") if fmt == "JPEG" else img
            img_out = img_out.resize(new_size, Image.LANCZOS)
        else:
            img_out = img

        tmp_path = f + ".tmp"
        if fmt == "WEBP":
            img_out.save(tmp_path, "WEBP", quality=WEBP_QUALITY, method=6)
        elif fmt in ("JPEG",):
            img_out.convert("RGB").save(tmp_path, "JPEG", quality=JPG_QUALITY, optimize=True)
        elif fmt == "PNG":
            img_out.save(tmp_path, "PNG", optimize=True)
        else:
            skipped.append(f)
            continue

        new_size_bytes = os.path.getsize(tmp_path)
        if new_size_bytes < orig_size:
            os.replace(tmp_path, f)
            total_before += orig_size
            total_after += new_size_bytes
            results.append((f, orig_size, new_size_bytes))
        else:
            os.remove(tmp_path)
            skipped.append(f)
    except Exception as e:
        errors.append((f, str(e)))

print(f"處理成功: {len(results)} 張")
print(f"跳過(已經夠小或無法縮小): {len(skipped)} 張")
print(f"錯誤: {len(errors)} 張")
for e in errors[:10]:
    print("  ERROR:", e)

print(f"\n總大小: {total_before/1024/1024:.1f}MB -> {total_after/1024/1024:.1f}MB")
if total_before:
    print(f"節省: {(1 - total_after/total_before)*100:.1f}%")

# top 10 biggest savings
results.sort(key=lambda x: x[1]-x[2], reverse=True)
print("\n前10大節省:")
for f, b, a in results[:10]:
    print(f"  {f}: {b/1024:.0f}KB -> {a/1024:.0f}KB")
