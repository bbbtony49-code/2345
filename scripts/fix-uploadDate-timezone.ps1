# 修正全站 VideoObject 結構化資料的 uploadDate 缺少時區問題
# 把 "2026-07-15" 改成 "2026-07-15T12:00:00+08:00"（台灣時區 UTC+8）
$files = Get-ChildItem -Path . -Filter *.html
$count = 0

foreach ($f in $files) {
    $c = Get-Content $f.FullName -Raw -Encoding UTF8
    if ($c -match '"uploadDate": "2026-07-15"') {
        $c = $c -replace '"uploadDate": "2026-07-15"', '"uploadDate": "2026-07-15T12:00:00+08:00"'
        [System.IO.File]::WriteAllText($f.FullName, $c, [System.Text.Encoding]::UTF8)
        Write-Host "$($f.Name) 已修正 uploadDate 時區" -ForegroundColor Green
        $count++
    }
}

Write-Host ""
Write-Host "共修正 $count 個檔案" -ForegroundColor Cyan
