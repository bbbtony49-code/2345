$f = ".\chef.html"
$c = Get-Content $f -Raw -Encoding UTF8

$old = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Behind the Scenes</span>
            <h2 class="section-title">主廚團隊飯店級實錄</h2>
            <p class="section-desc">從備料到出餐，主廚團隊維持一貫的飯店級標準，這是舒苑對品質的堅持。</p>
        </div>
        <div class="video-wrapper" style="max-width:420px; margin:0 auto; aspect-ratio: 9/16;">
            <video controls poster="assets/images/video-posters/主廚團隊飯店實錄.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                <source src="assets/videos/主廚團隊飯店實錄.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="portfolio.html" class="btn">查看更多實例作品</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "主廚團隊飯店級實錄",
        "description": "從備料到出餐，主廚團隊維持一貫的飯店級標準，這是舒苑對品質的堅持。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/主廚團隊飯店實錄.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/主廚團隊飯店實錄.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT2M4S",
        "publisher": {
            "@type": "Organization",
            "name": "舒苑飲食文化｜Luxury Private Chef",
            "logo": { "@type": "ImageObject", "url": "https://shuyuan-chef.com/assets/images/頂級龍蝦擺盤.webp" }
        }
    }
    </script>

    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Live Cooking Record</span>
            <h2 class="section-title">主廚現場料理花絮</h2>
            <p class="section-desc">近距離直擊林東立主廚在專業廚房現場料理與擺盤過程，展現二十年功底練就的細膩手法。</p>
        </div>
        <div class="video-wrapper" style="max-width:420px; margin:0 auto; aspect-ratio: 9/16;">
            <video controls poster="assets/images/video-posters/chef-intro.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                <source src="assets/videos/chef-intro.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="portfolio.html" class="btn">查看更多實例作品</a>
        </div>
    </section>
'@

$new = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Behind the Scenes</span>
            <h2 class="section-title">主廚團隊實錄影片</h2>
            <p class="section-desc">從飯店級出餐標準到現場料理花絮，近距離直擊林東立主廚團隊的專業日常。</p>
        </div>
        <div class="video-grid">
            <div class="video-card">
                <div class="video-wrapper" style="aspect-ratio: 9/16;">
                    <video controls poster="assets/images/video-posters/主廚團隊飯店實錄.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                        <source src="assets/videos/主廚團隊飯店實錄.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>主廚團隊飯店級實錄</h3>
                <p>從備料到出餐，主廚團隊維持一貫的飯店級標準，這是舒苑對品質的堅持。</p>
            </div>
            <div class="video-card">
                <div class="video-wrapper" style="aspect-ratio: 9/16;">
                    <video controls poster="assets/images/video-posters/chef-intro.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                        <source src="assets/videos/chef-intro.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>主廚現場料理花絮</h3>
                <p>近距離直擊林東立主廚在專業廚房現場料理與擺盤過程，展現二十年功底練就的細膩手法。</p>
            </div>
        </div>
        <div class="section-cta">
            <a href="portfolio.html" class="btn">查看更多實例作品</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "主廚團隊飯店級實錄",
        "description": "從備料到出餐，主廚團隊維持一貫的飯店級標準，這是舒苑對品質的堅持。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/主廚團隊飯店實錄.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/主廚團隊飯店實錄.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT2M4S",
        "publisher": {
            "@type": "Organization",
            "name": "舒苑飲食文化｜Luxury Private Chef",
            "logo": { "@type": "ImageObject", "url": "https://shuyuan-chef.com/assets/images/頂級龍蝦擺盤.webp" }
        }
    }
    </script>
'@

if ($c.Contains($old)) {
    $c = $c.Replace($old, $new)
    [System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
    Write-Host "chef.html 影片區塊已合併" -ForegroundColor Green
} else {
    Write-Host "chef.html 找不到比對區塊，需要人工檢查" -ForegroundColor Red
}
