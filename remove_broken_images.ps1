# Remove broken image references (5 spots) without replacing with new photos.
# 1) Removes 3 broken <img class="page-hero-bg"> lines (portfolio-corporate, portfolio-western, areas)
# 2) Removes the poster="assets/images/video-poster.jpg" attribute from <video> tags (portfolio.html x3, private-chef.html x1)
#
# Usage:
#   1. Put this file in C:\Users\user\Desktop\2345-repo
#   2. Open PowerShell in that folder
#   3. Run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   4. Run: .\remove_broken_images.ps1

[Environment]::CurrentDirectory = $PWD.Path
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Remove-LineContaining {
    param($FilePath, $MatchText, $Label)
    if (-not (Test-Path $FilePath)) {
        Write-Host "SKIP (file not found): $FilePath" -ForegroundColor Red
        return
    }
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    $newLines = New-Object System.Collections.Generic.List[string]
    $removed = 0
    foreach ($line in $lines) {
        if ($line -like "*$MatchText*") {
            $removed++
        } else {
            $newLines.Add($line)
        }
    }
    if ($removed -gt 0) {
        [System.IO.File]::WriteAllText($FilePath, ($newLines -join [Environment]::NewLine), $Utf8NoBom)
        Write-Host "REMOVED $removed line(s) from $Label" -ForegroundColor Green
    } else {
        Write-Host "NOT FOUND in $Label (already clean?)" -ForegroundColor Yellow
    }
}

function Remove-PosterAttribute {
    param($FilePath, $Label)
    if (-not (Test-Path $FilePath)) {
        Write-Host "SKIP (file not found): $FilePath" -ForegroundColor Red
        return
    }
    $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $target = ' poster="assets/images/video-poster.jpg"'
    $count = ([regex]::Matches($content, [regex]::Escape($target))).Count
    if ($count -gt 0) {
        $newContent = $content.Replace($target, "")
        [System.IO.File]::WriteAllText($FilePath, $newContent, $Utf8NoBom)
        Write-Host "REMOVED $count poster attribute(s) from $Label" -ForegroundColor Green
    } else {
        Write-Host "NOT FOUND in $Label (already clean?)" -ForegroundColor Yellow
    }
}

Write-Host "Processing hero background images..." -ForegroundColor Cyan
Remove-LineContaining -FilePath "portfolio-corporate.html" -MatchText "487238634_1075483994595382_3190290818542064618_n.jpg" -Label "portfolio-corporate.html"
Remove-LineContaining -FilePath "portfolio-western.html"   -MatchText "500044725_1216216306870062_8100589112948631894_n.jpg" -Label "portfolio-western.html"
Remove-LineContaining -FilePath "areas.html"                -MatchText "case-luxury-home-birthday.jpg" -Label "areas.html"

Write-Host ""
Write-Host "Processing video poster attributes..." -ForegroundColor Cyan
Remove-PosterAttribute -FilePath "portfolio.html"     -Label "portfolio.html"
Remove-PosterAttribute -FilePath "private-chef.html"  -Label "private-chef.html"

Write-Host ""
Write-Host "========== DONE ==========" -ForegroundColor Cyan
