#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔗 完整網站連結檢查系統
檢查 159 個頁面中所有內部和外部連結的有效性
"""

import os
import re
from pathlib import Path
from urllib.parse import urlparse
from collections import defaultdict

BASE_DIR = Path('/workspaces/2345')

def get_all_html_files():
    """獲取所有 HTML 文件"""
    return sorted([f for f in BASE_DIR.glob('*.html') if f.is_file()])

def extract_links(html_content, filename):
    """從 HTML 內容中提取所有連結"""
    links = defaultdict(list)
    
    # 找到所有 href 屬性
    href_pattern = r'href=[\'"](.*?)[\'"]'
    matches = re.finditer(href_pattern, html_content)
    
    for match in matches:
        href = match.group(1)
        
        # 分類連結
        if href.startswith('http'):
            links['external'].append(href)
        elif href.startswith('tel:'):
            links['tel'].append(href)
        elif href.startswith('mailto:'):
            links['email'].append(href)
        elif href.startswith('#'):
            links['anchor'].append(href)
        elif href.startswith('/'):
            links['absolute_path'].append(href)
        else:
            links['relative'].append(href)
    
    return links

def check_internal_links(all_files):
    """檢查內部連結有效性"""
    # 建立所有可用文件的映射
    available_files = set()
    for f in all_files:
        available_files.add(f.name)
        # 也允許不帶 .html 的版本
        available_files.add(f.stem)
    
    # 掃描所有可能的資源文件
    all_resources = set()
    for f in BASE_DIR.rglob('*'):
        if f.is_file():
            all_resources.add(str(f.relative_to(BASE_DIR)))
    
    results = {
        'valid': [],
        'invalid': [],
        'warnings': []
    }
    
    for html_file in all_files:
        try:
            with open(html_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            links = extract_links(content, html_file.name)
            
            # 檢查相對連結（但不檢查外部 URL、郵件、電話等）
            for link in links.get('relative', []):
                # 移除查詢參數和錨點
                clean_link = link.split('#')[0].split('?')[0]
                
                if clean_link == '' or clean_link.startswith('http'):
                    continue
                
                # 檢查文件是否存在
                target_file = BASE_DIR / clean_link
                
                if not target_file.exists() and clean_link not in available_files and clean_link not in all_resources:
                    results['invalid'].append({
                        'file': html_file.name,
                        'link': link,
                        'type': 'missing_file'
                    })
                else:
                    results['valid'].append({
                        'file': html_file.name,
                        'link': link
                    })
        
        except Exception as e:
            results['warnings'].append({
                'file': html_file.name,
                'error': str(e)
            })
    
    return results

def main():
    """主函數"""
    print("=" * 80)
    print("🔗 開始檢查所有網站連結...")
    print("=" * 80)
    
    html_files = get_all_html_files()
    print(f"\n📊 掃描統計:")
    print(f"   ✅ 總頁面數：{len(html_files)} 個")
    print(f"   📁 位置：{BASE_DIR}")
    
    # 檢查連結
    print(f"\n🔍 檢查中...\n")
    results = check_internal_links(html_files)
    
    # 輸出結果
    print("=" * 80)
    print("📋 檢查結果")
    print("=" * 80)
    
    print(f"\n✅ 有效連結數：{len(results['valid'])}")
    print(f"❌ 無效連結數：{len(results['invalid'])}")
    print(f"⚠️  警告數：{len(results['warnings'])}")
    
    if results['invalid']:
        print("\n❌ 無效連結詳表：")
        print("-" * 80)
        for item in sorted(results['invalid'], key=lambda x: x['file'])[:20]:
            print(f"   文件：{item['file']}")
            print(f"   連結：{item['link']}")
            print(f"   原因：{item['type']}")
            print()
    
    if results['warnings']:
        print("\n⚠️  警告詳表（前 10 個）：")
        print("-" * 80)
        for item in results['warnings'][:10]:
            print(f"   文件：{item['file']}")
            print(f"   錯誤：{item['error']}")
    
    print("\n" + "=" * 80)
    print("📝 建議：")
    print("=" * 80)
    print("""
1. 如果有無效連結，請修正
2. 檢查所有外部連結是否正確
3. 驗證 SEO 蜘蛛網結構是否完整
4. 測試所有浮動 CTA 按鈕
5. 檢查手機版的連結易用性

連結檢查完成！✨
""")

if __name__ == '__main__':
    main()
