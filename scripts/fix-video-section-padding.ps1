# 全站影片區塊瘦身：把 video-section 的上下留白從預設的 5.2rem 縮小到 3.5rem
# 這個改動是「加新規則」，不是改舊規則，所以不會影響其他非影片的 section
$f = ".\css\style.css"
$c = Get-Content $f -Raw -Encoding UTF8

$anchor = "/* ===== Video Section ===== */`n.video-section {`n    background: var(--bg);`n}"

$replacement = @'
/* ===== Video Section ===== */
.video-section {
    background: var(--bg);
    padding: 3.5rem 5%;
}
'@

if ($c.Contains($anchor)) {
    $c = $c.Replace($anchor, $replacement)
    [System.IO.File]::WriteAllText($f, $c, [System.Text.Encoding]::UTF8)
    Write-Host "style.css 已縮小 video-section 上下留白" -ForegroundColor Green
} else {
    Write-Host "style.css 找不到比對區塊，需要人工檢查" -ForegroundColor Red
}
