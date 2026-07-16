$f = ".\corporate-catering-tailend.html"
$c = Get-Content $f -Raw -Encoding UTF8

$old = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Live Production</span>
            <h2 class="section-title">百人尾牙春酒 Buffet 現場製作</h2>
            <p class="section-desc">百人規模的尾牙春酒場合，團隊現場即時製作 Buffet 料理，兼顧效率與品質。</p>
        </div>
        <div class="video-wrapper" style="max-width:800px;margin:0 auto;">
            <video controls poster="assets/images/video-posters/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.jpg" preload="none">
                <source src="assets/videos/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="pricing-private-chef.html" class="btn">了解尾牙春酒報價</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "百人尾牙春酒 Buffet 現場製作",
        "description": "百人規模的尾牙春酒場合，團隊現場即時製作 Buffet 料理，兼顧效率與品質。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT42S",
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
            <h2 class="section-title">節慶百人 Buffet 現場製作實錄</h2>
            <p class="section-desc">聖誕節、尾牙等節慶百人自助餐現場實錄，團隊同步備料、烹調與擺台，確保賓客用餐體驗一致穩定。</p>
        </div>
        <div class="video-wrapper" style="max-width:800px;margin:0 auto;">
            <video controls poster="assets/images/video-posters/私廚聖誕節百人buffet現場製作.jpg" preload="none">
                <source src="assets/videos/私廚聖誕節百人buffet現場製作.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="contact.html" class="btn">預約節慶外燴</a>
        </div>
    </section>
'@

$new = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Live Production</span>
            <h2 class="section-title">百人 Buffet 現場製作實錄</h2>
            <p class="section-desc">從尾牙春酒到聖誕節慶，團隊同步備料、烹調與擺台，確保百人規模用餐體驗一致穩定。</p>
        </div>
        <div class="video-grid">
            <div class="video-card">
                <div class="video-wrapper">
                    <video controls poster="assets/images/video-posters/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.jpg" preload="none">
                        <source src="assets/videos/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>百人尾牙春酒 Buffet 現場製作</h3>
                <p>百人規模的尾牙春酒場合，團隊現場即時製作 Buffet 料理，兼顧效率與品質。</p>
            </div>
            <div class="video-card">
                <div class="video-wrapper">
                    <video controls poster="assets/images/video-posters/私廚聖誕節百人buffet現場製作.jpg" preload="none">
                        <source src="assets/videos/私廚聖誕節百人buffet現場製作.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>節慶百人 Buffet 現場製作實錄</h3>
                <p>聖誕節、尾牙等節慶百人自助餐現場實錄，團隊同步備料、烹調與擺台，確保賓客用餐體驗一致穩定。</p>
            </div>
        </div>
        <div class="section-cta">
            <a href="pricing-private-chef.html" class="btn">了解尾牙春酒報價</a>
            <a href="contact.html" class="btn">預約節慶外燴</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "百人尾牙春酒 Buffet 現場製作",
        "description": "百人規模的尾牙春酒場合，團隊現場即時製作 Buffet 料理，兼顧效率與品質。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/私廚百人餐宴尾牙春酒團隊現場buffet料理製作.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT42S",
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
    Write-Host "corporate-catering-tailend.html 影片區塊已合併" -ForegroundColor Green
} else {
    Write-Host "corporate-catering-tailend.html 找不到比對區塊，需要人工檢查" -ForegroundColor Red
}
