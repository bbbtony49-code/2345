$f = ".\vip-banquet-yacht.html"
$c = Get-Content $f -Raw -Encoding UTF8

$old = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Signature Case</span>
            <h2 class="section-title">遊艇餐宴經典實錄</h2>
            <p class="section-desc">海上高端場域的餐宴執行，是舒苑團隊最具代表性的經典案例之一。</p>
        </div>
        <div class="video-wrapper" style="max-width:800px;margin:0 auto;">
            <video controls poster="assets/images/video-posters/主廚團隊遊艇實錄超經典.jpg" preload="none">
                <source src="assets/videos/主廚團隊遊艇實錄超經典.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="portfolio.html" class="btn">查看更多遊艇案例</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "遊艇餐宴經典實錄",
        "description": "海上高端場域的餐宴執行，是舒苑團隊最具代表性的經典案例之一。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/主廚團隊遊艇實錄超經典.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/主廚團隊遊艇實錄超經典.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT1M47S",
        "publisher": {
            "@type": "Organization",
            "name": "舒苑飲食文化｜Luxury Private Chef",
            "logo": { "@type": "ImageObject", "url": "https://shuyuan-chef.com/assets/images/頂級龍蝦擺盤.webp" }
        }
    }
    </script>

    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Signature Case</span>
            <h2 class="section-title">遊艇出餐風景實錄</h2>
            <p class="section-desc">夜幕降臨的城市天際線與遊艇甲板相映，主廚團隊在海上為賓客打造獨一無二的用餐場景。</p>
        </div>
        <div class="video-wrapper" style="max-width:420px; margin:0 auto; aspect-ratio: 9/16;">
            <video controls poster="assets/images/video-posters/遊艇出餐風景.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                <source src="assets/videos/遊艇出餐風景.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="contact.html" class="btn">預約遊艇餐宴</a>
        </div>
    </section>
'@

$new = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Signature Case</span>
            <h2 class="section-title">遊艇餐宴實錄</h2>
            <p class="section-desc">海上高端場域的餐宴執行，是舒苑團隊最具代表性的經典案例之一。</p>
        </div>
        <div class="video-grid">
            <div class="video-card">
                <div class="video-wrapper">
                    <video controls poster="assets/images/video-posters/主廚團隊遊艇實錄超經典.jpg" preload="none">
                        <source src="assets/videos/主廚團隊遊艇實錄超經典.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>遊艇餐宴經典實錄</h3>
                <p>海上高端場域的餐宴執行，是舒苑團隊最具代表性的經典案例之一。</p>
            </div>
            <div class="video-card">
                <div class="video-wrapper" style="aspect-ratio: 9/16;">
                    <video controls poster="assets/images/video-posters/遊艇出餐風景.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                        <source src="assets/videos/遊艇出餐風景.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>遊艇出餐風景實錄</h3>
                <p>夜幕降臨的城市天際線與遊艇甲板相映，主廚團隊在海上為賓客打造獨一無二的用餐場景。</p>
            </div>
        </div>
        <div class="section-cta">
            <a href="portfolio.html" class="btn">查看更多遊艇案例</a>
            <a href="contact.html" class="btn">預約遊艇餐宴</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "遊艇餐宴經典實錄",
        "description": "海上高端場域的餐宴執行，是舒苑團隊最具代表性的經典案例之一。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/主廚團隊遊艇實錄超經典.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/主廚團隊遊艇實錄超經典.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT1M47S",
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
    Write-Host "vip-banquet-yacht.html 影片區塊已合併" -ForegroundColor Green
} else {
    Write-Host "vip-banquet-yacht.html 找不到比對區塊，需要人工檢查" -ForegroundColor Red
}
