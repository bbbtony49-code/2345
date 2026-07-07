# Insert Open Graph (og:*) tags into every html page that does not already have og:title
# Reuses each page's own <title>, meta description, canonical url, and first image found in the page.
# Falls back to a default image if the page has no image reference.
#
# Usage:
#   1. Put this file in C:\Users\user\Desktop\2345-repo (same folder as areas-taoyuan.html)
#   2. Open PowerShell in that folder
#   3. Run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   4. Run: .\insert_og_tags.ps1

$Domain = "https://shuyuan-chef.com"
$DefaultImage = "$Domain/assets/images/real-banquet-hall-tables.jpg"
$Extensions = @("*.html", "*.htm")
$SkipFiles = @("HTML_TEMPLATE_STANDARD.html")

$InsertedCount = 0
$SkippedHasOg = 0
$SkippedRedirect = 0
$SkippedNoHead = 0
$SkippedTemplate = 0

Write-Host "Scanning..." -ForegroundColor Cyan

Get-ChildItem -Path . -Recurse -Include $Extensions -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\'
} | ForEach-Object {
    $fileName = $_.Name
    $filePath = $_.FullName

    if ($SkipFiles -contains $fileName) {
        $script:SkippedTemplate++
        return
    }

    $content = Get-Content -Path $filePath -Raw -Encoding UTF8

    if ($content -match '(?i)http-equiv\s*=\s*.refresh.') {
        $script:SkippedRedirect++
        return
    }

    if ($content -match '(?i)og:title') {
        $script:SkippedHasOg++
        return
    }

    $titleMatch = [regex]::Match($content, '(?is)<title>(.*?)</title>')
    $pageTitle = "Luxury Private Chef - Shuyuan"
    if ($titleMatch.Success) { $pageTitle = $titleMatch.Groups[1].Value.Trim() }

    $descPattern = '(?i)name\s*=\s*.description.\s+content\s*=\s*"([^"]*)"'
    $descMatch = [regex]::Match($content, $descPattern)
    $pageDesc = "Private chef and catering service based in Taiwan."
    if ($descMatch.Success) { $pageDesc = $descMatch.Groups[1].Value.Trim() }

    $canonicalPattern = '(?i)rel\s*=\s*.canonical.\s+href\s*=\s*"([^"]*)"'
    $canonicalMatch = [regex]::Match($content, $canonicalPattern)
    $pageUrl = "$Domain/$fileName"
    if ($canonicalMatch.Success) { $pageUrl = $canonicalMatch.Groups[1].Value.Trim() }

    $imgPattern = '(?i)assets/images/[^"]+\.(jpg|jpeg|png|webp)'
    $imgMatch = [regex]::Match($content, $imgPattern)
    $pageImage = $DefaultImage
    if ($imgMatch.Success) { $pageImage = "$Domain/$($imgMatch.Value)" }

    $quoteChar = [char]34
    $ampEntity = [char]38 + "quot;"
    $pageTitleEsc = $pageTitle.Replace([string]$quoteChar, $ampEntity)
    $pageDescEsc = $pageDesc.Replace([string]$quoteChar, $ampEntity)

    $nl = [Environment]::NewLine
    $ogBlock = '    <meta property="og:title" content="' + $pageTitleEsc + '">' + $nl
    $ogBlock += '    <meta property="og:description" content="' + $pageDescEsc + '">' + $nl
    $ogBlock += '    <meta property="og:image" content="' + $pageImage + '">' + $nl
    $ogBlock += '    <meta property="og:url" content="' + $pageUrl + '">' + $nl
    $ogBlock += '    <meta property="og:type" content="website">' + $nl
    $ogBlock += '    <meta property="og:locale" content="zh_TW">' + $nl

    $headIndex = $content.IndexOf("</head>", [StringComparison]::OrdinalIgnoreCase)

    if ($headIndex -ge 0) {
        $newContent = $content.Substring(0, $headIndex) + $ogBlock + $content.Substring($headIndex)
        [System.IO.File]::WriteAllText($filePath, $newContent, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "INSERTED: $fileName" -ForegroundColor Green
        $script:InsertedCount++
    } else {
        Write-Host "SKIP (no head tag found): $fileName" -ForegroundColor Red
        $script:SkippedNoHead++
    }
}

Write-Host ""
Write-Host "========== DONE ==========" -ForegroundColor Cyan
Write-Host "OG tags inserted: $InsertedCount"
Write-Host "Skipped (already had og:title): $SkippedHasOg"
Write-Host "Skipped (redirect stub page): $SkippedRedirect"
Write-Host "Skipped (template file): $SkippedTemplate"
Write-Host "Skipped (no head tag found): $SkippedNoHead"
