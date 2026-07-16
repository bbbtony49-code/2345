# Re-insert real photos into the 5 spots that were previously cleaned up.
# Requires the 5 new image files to already be placed in assets/images/ before running this.
#
# Usage:
#   1. Copy the 5 downloaded images into: C:\Users\user\Desktop\2345-repo\assets\images\
#      - corporate-case-dessert-table.jpg
#      - western-lobster-plating.jpg
#      - team-service-areas.jpg
#      - video-poster-kitchen.jpg
#      - video-poster-banquet.jpg
#   2. Put this script in C:\Users\user\Desktop\2345-repo
#   3. Open PowerShell there
#   4. Run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   5. Run: .\add_real_images.ps1

[Environment]::CurrentDirectory = $PWD.Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Insert-HeroImage {
    param($FilePath, $ImagePath, $AltText, $Label)
    if (-not (Test-Path $FilePath)) {
        Write-Host "SKIP (page not found): $FilePath" -ForegroundColor Red
        return
    }
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8

    if ($content -match [regex]::Escape($ImagePath)) {
        Write-Host "SKIP (already inserted): $Label" -ForegroundColor Yellow
        return
    }

    $marker = '<section class="page-hero">'
    $idx = $content.IndexOf($marker)
    if ($idx -lt 0) {
        Write-Host "FAILED (no page-hero section found): $Label" -ForegroundColor Red
        return
    }

    $insertPos = $idx + $marker.Length
    $imgTag = "`n        <img src=`"/$ImagePath`" alt=`"$AltText`" class=`"page-hero-bg`" loading=`"eager`" fetchpriority=`"high`">"

    $newContent = $content.Substring(0, $insertPos) + $imgTag + $content.Substring($insertPos)
    [System.IO.File]::WriteAllText($FilePath, $newContent, $Utf8NoBom)
    Write-Host "INSERTED hero image: $Label" -ForegroundColor Green
}

function Insert-VideoPoster {
    param($FilePath, $ImagePath, $Label)
    if (-not (Test-Path $FilePath)) {
        Write-Host "SKIP (page not found): $FilePath" -ForegroundColor Red
        return
    }
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8

    $target = '<video controls preload="none">'
    $count = ([regex]::Matches($content, [regex]::Escape($target))).Count

    if ($count -eq 0) {
        Write-Host "SKIP (no bare video tag found, maybe already has poster): $Label" -ForegroundColor Yellow
        return
    }

    $replacement = "<video controls poster=`"$ImagePath`" preload=`"none`">"
    $newContent = $content.Replace($target, $replacement)
    [System.IO.File]::WriteAllText($FilePath, $newContent, $Utf8NoBom)
    Write-Host "INSERTED poster ($count video tag(s)): $Label" -ForegroundColor Green
}

Write-Host "Inserting hero images..." -ForegroundColor Cyan
Insert-HeroImage -FilePath "portfolio-corporate.html" -ImagePath "assets/images/corporate-case-dessert-table.jpg" -AltText "大型企業活動作品" -Label "portfolio-corporate.html"
Insert-HeroImage -FilePath "portfolio-western.html"   -ImagePath "assets/images/western-lobster-plating.jpg"    -AltText "西式套餐作品"     -Label "portfolio-western.html"
Insert-HeroImage -FilePath "areas.html"                -ImagePath "assets/images/team-service-areas.jpg"        -AltText "服務地區｜Luxury Private Chef - 舒苑飲食文化" -Label "areas.html"

Write-Host ""
Write-Host "Inserting video posters..." -ForegroundColor Cyan
Insert-VideoPoster -FilePath "portfolio.html"    -ImagePath "assets/images/video-poster-kitchen.jpg" -Label "portfolio.html"
Insert-VideoPoster -FilePath "private-chef.html" -ImagePath "assets/images/video-poster-banquet.jpg" -Label "private-chef.html"

Write-Host ""
Write-Host "========== DONE ==========" -ForegroundColor Cyan
