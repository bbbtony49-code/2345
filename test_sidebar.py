#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
📱 側邊菜單測試與診斷工具
幫助診斷手機上側邊菜單無法顯示的問題
"""

import os
from pathlib import Path

BASE_DIR = Path('/workspaces/2345')

def check_sidebar_structure():
    """檢查側邊菜單結構"""
    print("=" * 80)
    print("📱 側邊菜單結構檢查")
    print("=" * 80)
    
    # 檢查索引頁
    index_file = BASE_DIR / 'index.html'
    with open(index_file, 'r', encoding='utf-8') as f:
        index_content = f.read()
    
    checks = {
        'nav 元素': '<nav id="navbar">' in index_content,
        'nav-toggle 按鈕': '<button class="nav-toggle"' in index_content,
        'sidebar-overlay': '<div class="sidebar-overlay"></div>' in index_content,
        'sidebar-nav': '<div class="sidebar-nav">' in index_content,
        'sidebar 菜單項': '<div class="sidebar-nav">' in index_content and 'href="index.html"' in index_content,
    }
    
    print("\n✅ HTML 結構檢查:\n")
    for check_name, result in checks.items():
        status = "✅" if result else "❌"
        print(f"   {status} {check_name}")
    
    # 檢查 CSS
    css_file = BASE_DIR / 'css' / 'style.css'
    with open(css_file, 'r', encoding='utf-8') as f:
        css_content = f.read()
    
    css_checks = {
        '.sidebar-nav 定義': '.sidebar-nav {' in css_content,
        '.sidebar-overlay 定義': '.sidebar-overlay {' in css_content,
        '.sidebar-nav.active': '.sidebar-nav.active {' in css_content,
        '轉換動畫': 'translateX(-100%)' in css_content,
        '移動設備媒體查詢': '@media (max-width: 768px)' in css_content,
        '移動設備側邊菜單樣式': '@media (max-width: 768px)' in css_content and '.sidebar-nav' in css_content,
    }
    
    print("\n✅ CSS 檢查:\n")
    for check_name, result in css_checks.items():
        status = "✅" if result else "❌"
        print(f"   {status} {check_name}")
    
    # 檢查 JavaScript
    js_file = BASE_DIR / 'js' / 'main.js'
    with open(js_file, 'r', encoding='utf-8') as f:
        js_content = f.read()
    
    js_checks = {
        'sidebar 元素查詢': "document.querySelector('.sidebar-overlay')" in js_content,
        '點擊事件綁定': "addEventListener('click'" in js_content,
        '菜單切換邏輯': '.classList.toggle' in js_content,
        '診斷信息': "console.log" in js_content,
        'DOMContentLoaded': "DOMContentLoaded" in js_content,
    }
    
    print("\n✅ JavaScript 檢查:\n")
    for check_name, result in js_checks.items():
        status = "✅" if result else "❌"
        print(f"   {status} {check_name}")
    
    return all(checks.values()) and all(css_checks.values()) and all(js_checks.values())

def print_testing_guide():
    """打印測試指南"""
    print("\n" + "=" * 80)
    print("📋 手機測試指南")
    print("=" * 80)
    
    guide = """
【測試步驟】

1️⃣  打開瀏覽器開發者工具 (DevTools)
   • Chrome/Edge: 按 F12 或 Ctrl+Shift+I（Windows）或 Cmd+Option+I（Mac）
   • Firefox: 按 F12 或 Ctrl+Shift+I（Windows）或 Cmd+Option+I（Mac）

2️⃣  進入開發者工具
   • 點擊「Console」標籤
   • 刷新頁面

3️⃣  查看診斷信息
   應該看到類似以下的輸出：
   
   🔍 側邊菜單初始化檢查：
   ✓ navToggle: ✅ 找到
   ✓ sidebarNav: ✅ 找到
   ✓ sidebarOverlay: ✅ 找到
   ✅ 所有元素已找到，開始綁定事件...
   ✅ 所有事件綁定完成！

4️⃣  模擬手機屏幕
   • 按 Ctrl+Shift+M（Windows）或 Cmd+Shift+M（Mac）進入響應式設計模式
   • 或按 F12 後在右上角選擇設備類型

5️⃣  測試側邊菜單
   • 點擊右上角的漢堡菜單按鈕（☰）
   • 查看 Console 中是否出現「漢堡菜單點擊」的消息
   • 菜單應該從左邊滑出（寬度 260px）
   • 蒙層應該出現（半透明黑色背景）

6️⃣  測試菜單互動
   • 點擊菜單項目，應該看到「菜單項目點擊」的消息
   • 點擊蒙層，應該看到「蒙層點擊」的消息
   • 菜單應該隱藏

【常見問題診斷】

❌ 問題：Console 看不到診斷信息
   ✅ 解決：
      1. 重新刷新頁面 (Ctrl+R 或 Cmd+R)
      2. 檢查是否有 JavaScript 錯誤（紅色消息）
      3. 確保在正確的頁面上（不是空白頁）

❌ 問題：看到「所有元素已找到」但漢堡菜單點擊沒有反應
   ✅ 解決：
      1. 檢查 CSS 是否加載：在 DevTools 中檢查 Elements 標籤
      2. 查看是否有 CSS 錯誤
      3. 確保在移動設備尺寸（≤768px）

❌ 問題：菜單出現但沒有動畫效果
   ✅ 解決：
      1. 檢查 CSS 中是否有 transform 和 transition
      2. 檢查瀏覽器是否支持 CSS 動畫

❌ 問題：漢堡菜單按鈕看不到
   ✅ 解決：
      1. 確認在移動設備尺寸（寬度 ≤768px）
      2. 檢查按鈕的 CSS 是否有 display: inline-flex
      3. 在桌面上它應該隱藏

【所有元素都正常工作時的表現】

✅ 漢堡菜單按鈕在手機上可見（☰）
✅ 點擊按鈕後菜單從左邊滑出（300ms 動畫）
✅ 蒙層出現（半透明黑色，可點擊關閉）
✅ 按鈕變成關閉圖標（✕）
✅ 點擊菜單項目後自動隱藏菜單
✅ Console 中有完整的診斷信息
✅ 在桌面設備上，漢堡菜單和側邊菜單都隱藏

【如果仍有問題】

1. 打開 DevTools -> Console
2. 複製所有錯誤信息
3. 檢查 Network 標籤確保 CSS 和 JS 文件已加載
4. 在不同瀏覽器上測試（Chrome, Firefox, Safari）
"""
    
    print(guide)

def main():
    """主函數"""
    print("\n")
    
    # 檢查結構
    all_ok = check_sidebar_structure()
    
    # 打印測試指南
    print_testing_guide()
    
    # 總結
    print("\n" + "=" * 80)
    print("✅ 準備工作完成！")
    print("=" * 80)
    
    if all_ok:
        print("""
✅ 所有結構檢查都通過了
👉 請按照「手機測試指南」的步驟進行測試
        """)
    else:
        print("""
⚠️  某些檢查未通過，請檢查上面的結果
        """)

if __name__ == '__main__':
    main()
