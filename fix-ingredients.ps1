$f = ".\ingredients.html"
$c = Get-Content $f -Raw -Encoding UTF8

$old = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Ingredients</span>
            <h2 class="section-title">鮮活嚴選海鮮在這</h2>
            <p class="section-desc">從龍蝦、干貝到黑鮪魚，主廚團隊每日嚴選最新鮮的活海鮮，直擊挑選與處理的第一現場。</p>
        </div>
        <div class="video-wrapper" style="max-width:420px; margin:0 auto; aspect-ratio: 9/16;">
            <video controls poster="assets/images/video-posters/鮮活嚴選海鮮在這.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                <source src="assets/videos/鮮活嚴選海鮮在這.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="ingredients-lobster.html" class="btn">了解進口澳洲龍蝦</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "鮮活嚴選海鮮在這",
        "description": "舒苑飲食文化嚴選海鮮實錄，主廚團隊每日挑選龍蝦、干貝、黑鮪魚等新鮮活海鮮，直擊食材把關第一現場。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/鮮活嚴選海鮮在這.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/鮮活嚴選海鮮在這.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT18S",
        "publisher": {
            "@type": "Organization",
            "name": "舒苑飲食文化｜Luxury Private Chef",
            "logo": { "@type": "ImageObject", "url": "https://shuyuan-chef.com/assets/images/頂級龍蝦擺盤.webp" }
        }
    }
    </script>

    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Ingredients</span>
            <h2 class="section-title">生蠔料理實錄</h2>
            <p class="section-desc">嚴選新鮮生蠔，透過主廚手法呈現最鮮甜的風味層次。</p>
        </div>
        <div class="video-wrapper" style="max-width:800px;margin:0 auto;">
            <video controls poster="assets/images/video-posters/美味生蠔料裡.jpg" preload="none">
                <source src="assets/videos/美味生蠔料裡.mp4" type="video/mp4">
                您的瀏覽器不支援影片播放。
            </video>
        </div>
        <div class="section-cta">
            <a href="menu.html" class="btn">查看西式菜單方案</a>
        </div>
    </section>
'@

$new = @'
    <section class="video-section">
        <div class="section-header">
            <span class="section-sub">Ingredients</span>
            <h2 class="section-title">食材實錄影片</h2>
            <p class="section-desc">從活海鮮的每日嚴選，到生蠔料理的手法呈現，直擊主廚團隊對食材的堅持。</p>
        </div>
        <div class="video-grid">
            <div class="video-card">
                <div class="video-wrapper" style="aspect-ratio: 9/16;">
                    <video controls poster="assets/images/video-posters/鮮活嚴選海鮮在這.jpg" preload="none" style="width:100%; height:100%; object-fit:cover;">
                        <source src="assets/videos/鮮活嚴選海鮮在這.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>鮮活嚴選海鮮在這</h3>
                <p>從龍蝦、干貝到黑鮪魚，主廚團隊每日嚴選最新鮮的活海鮮，直擊挑選與處理的第一現場。</p>
            </div>
            <div class="video-card">
                <div class="video-wrapper">
                    <video controls poster="assets/images/video-posters/美味生蠔料裡.jpg" preload="none">
                        <source src="assets/videos/美味生蠔料裡.mp4" type="video/mp4">
                        您的瀏覽器不支援影片播放。
                    </video>
                </div>
                <h3>生蠔料理實錄</h3>
                <p>嚴選新鮮生蠔，透過主廚手法呈現最鮮甜的風味層次。</p>
            </div>
        </div>
        <div class="section-cta">
            <a href="ingredients-lobster.html" class="btn">了解進口澳洲龍蝦</a>
            <a href="menu.html" class="btn">查看西式菜單方案</a>
        </div>
    </section>
    <script type="application/ld+json">
    {
        "@context": "https://schema.org",
        "@type": "VideoObject",
        "name": "鮮活嚴選海鮮在這",
        "description": "舒苑飲食文化嚴選海鮮實錄，主廚團隊每日挑選龍蝦、干貝、黑鮪魚等新鮮活海鮮，直擊食材把關第一現場。",
        "thumbnailUrl": "https://shuyuan-chef.com/assets/images/video-posters/鮮活嚴選海鮮在這.jpg",
        "contentUrl": "https://shuyuan-chef.com/assets/videos/鮮活嚴選海鮮在這.mp4",
        "uploadDate": "2026-07-15",
        "duration": "PT18S",
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
    Write-Host "ingredients.html 影片區塊已合併" -ForegroundColor Green
} else {
    Write-Host "ingredients.html 找不到比對區塊，需要人工檢查" -ForegroundColor Red
}
