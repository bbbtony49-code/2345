#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 為所有 HTML 頁面添加從左邊出來的側邊菜單
處理 159 個頁面的導航結構
"""

import os
import re
from pathlib import Path

BASE_DIR = Path('/workspaces/2345')

# 定義側邊菜單的 HTML 結構
SIDEBAR_MENU_HTML = '''    <!-- Sidebar Navigation -->
    <div class="sidebar-overlay"></div>
    <div class="sidebar-nav">
        <a href="index.html">首頁</a>
        <a href="private-chef.html">到府私廚</a>
        <a href="services.html">服務項目</a>
        <a href="chef.html">主廚介紹</a>
        <a href="portfolio.html">服務實例</a>
        <a href="menu.html">菜單方案</a>
        <a href="ingredients.html">嚴選食材</a>
        <a href="areas.html">服務地區</a>
        <a href="faq.html">Q&A</a>
        <a href="contact.html" style="margin-top: 1rem; padding-top: 1.5rem; border-top: 1px solid var(--border);">預約諮詢</a>
    </div>
'''

# 漢堡菜單按鈕 HTML
NAV_TOGGLE_HTML = '        <button class="nav-toggle" aria-expanded="false" aria-label="開啟導覽"><span></span></button>\n'

# JavaScript 代碼用於處理側邊菜單
SIDEBAR_JS = '''
// ===== Sidebar Navigation Toggle =====
const sidebarOverlay = document.querySelector('.sidebar-overlay');
const sidebarNav = document.querySelector('.sidebar-nav');
const navToggle = document.querySelector('.nav-toggle');

if (navToggle && sidebarNav && sidebarOverlay) {
    // Toggle 漢堡菜單
    navToggle.addEventListener('click', () => {
        const isActive = sidebarNav.classList.contains('active');
        sidebarNav.classList.toggle('active');
        sidebarOverlay.classList.toggle('active');
        navToggle.setAttribute('aria-expanded', String(!isActive));
        navToggle.classList.toggle('active');
    });

    // 點擊蒙層關閉菜單
    sidebarOverlay.addEventListener('click', () => {
        sidebarNav.classList.remove('active');
        sidebarOverlay.classList.remove('active');
        navToggle.classList.remove('active');
        navToggle.setAttribute('aria-expanded', 'false');
    });

    // 點擊菜單項目後關閉
    sidebarNav.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            sidebarNav.classList.remove('active');
            sidebarOverlay.classList.remove('active');
            navToggle.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
        });
    });
}
'''

def get_html_files():
    """獲取所有 HTML 文件"""
    html_files = sorted([f for f in BASE_DIR.glob('*.html') if f.is_file()])
    # 也獲取 blog/ 目錄下的 HTML 文件
    blog_html = sorted([f for f in BASE_DIR.glob('blog/*.html') if f.is_file()])
    return html_files + blog_html

def has_nav_toggle(content):
    """檢查是否已有 nav-toggle"""
    return 'nav-toggle' in content

def has_sidebar_menu(content):
    """檢查是否已有側邊菜單"""
    return 'sidebar-nav' in content

def add_nav_toggle(nav_str):
    """在導航結構中添加漢堡菜單按鈕"""
    if 'nav-toggle' in nav_str:
        return nav_str
    
    # 找到 nav-links div 後插入按鈕
    pattern = r'(<div class="nav-links">.*?</div>)'
    replacement = r'\1\n' + NAV_TOGGLE_HTML
    
    return re.sub(pattern, replacement, nav_str, flags=re.DOTALL)

def add_sidebar_menu(content):
    """在 body 開始後添加側邊菜單"""
    if 'sidebar-nav' in content:
        return content
    
    # 在 </nav> 之後添加側邊菜單
    pattern = r'(</nav>)'
    replacement = r'\1\n\n' + SIDEBAR_MENU_HTML
    
    content = re.sub(pattern, replacement, content, count=1)
    return content

def update_main_js(js_content):
    """在 main.js 中添加側邊菜單 JS 代碼"""
    if 'Sidebar Navigation Toggle' in js_content:
        return js_content
    
    # 在文件末尾（關閉 script 之前）添加
    # 如果沒有關閉 script 標籤，就直接在末尾添加
    return js_content.rstrip() + '\n\n' + SIDEBAR_JS

def process_html_file(filepath):
    """處理單個 HTML 文件"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 檢查是否已有菜單
        if has_sidebar_menu(content):
            return 'skip', '已有側邊菜單'
        
        # 添加側邊菜單
        content = add_sidebar_menu(content)
        
        # 添加 nav-toggle 按鈕（如果還沒有）
        if not has_nav_toggle(content):
            # 找到 nav-links 並添加按鈕
            content = re.sub(
                r'(<div class="nav-links">.*?</div>)',
                r'\1\n' + NAV_TOGGLE_HTML.rstrip(),
                content,
                flags=re.DOTALL
            )
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        
        return 'success', None
    
    except Exception as e:
        return 'error', str(e)

def main():
    """主函數"""
    print("=" * 80)
    print("🎯 為所有頁面添加從左邊出來的側邊菜單")
    print("=" * 80)
    
    html_files = get_html_files()
    print(f"\n📊 掃描統計:")
    print(f"   ✅ 總頁面數：{len(html_files)} 個")
    
    # 更新 main.js
    js_file = BASE_DIR / 'js' / 'main.js'
    if js_file.exists():
        with open(js_file, 'r', encoding='utf-8') as f:
            js_content = f.read()
        
        js_content = update_main_js(js_content)
        
        with open(js_file, 'w', encoding='utf-8') as f:
            f.write(js_content)
        
        print(f"   ✅ 已更新 main.js（側邊菜單控制代碼）")
    
    # 處理每個 HTML 文件
    print(f"\n🔄 正在更新...\n")
    
    success_count = 0
    skip_count = 0
    error_count = 0
    
    for html_file in html_files:
        status, error = process_html_file(html_file)
        
        if status == 'success':
            print(f"   ✅ {html_file.name}")
            success_count += 1
        elif status == 'skip':
            print(f"   ⏭️  {html_file.name} ({error})")
            skip_count += 1
        else:
            print(f"   ❌ {html_file.name}: {error}")
            error_count += 1
    
    # 輸出摘要
    print("\n" + "=" * 80)
    print("📋 更新摘要")
    print("=" * 80)
    print(f"✅ 成功更新：{success_count} 個文件")
    print(f"⏭️  已跳過（已有菜單）：{skip_count} 個文件")
    print(f"❌ 失敗：{error_count} 個文件")
    print(f"📊 總計：{len(html_files)} 個頁面")
    
    print("\n" + "=" * 80)
    print("🎉 側邊菜單添加完成！")
    print("=" * 80)
    print("""
【菜單功能】
✅ 所有頁面頂部都有漢堡菜單按鈕（☰）
✅ 點擊後菜單從左邊滑出
✅ 包含 9 個主要導航選項
✅ 點擊蒙層或菜單項自動隱藏
✅ 支持移動設備響應式設計

【下一步】
1. 在瀏覽器測試所有頁面的側邊菜單
2. 檢查菜單是否正確對齐和顯示
3. 測試菜單的打開/關閉動畫
4. 提交到 GitHub
""")

if __name__ == '__main__':
    main()
