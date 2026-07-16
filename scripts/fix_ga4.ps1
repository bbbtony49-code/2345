# Batch replace old GA4 ID with your own GA4 ID in all html files
# Usage:
#   1. Put this file in the repo folder (2345-repo, same folder as areas-taoyuan.html)
#   2. Open PowerShell in that folder
#   3. Run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   4. Run: .\fix_ga4.ps1

$OldId = "G-D8W8VG63FQ"
$NewId = "G-2P9MZY1F46"
$Extensions = @("*.html", "*.htm")

$TotalFiles = 0
$TotalReplacements = 0

Write-Host "Scanning..." -ForegroundColor Cyan

Get-ChildItem -Path . -Recurse -Include $Extensions -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\'
} | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content -Path $filePath -Raw -Encoding UTF8

    if ($content -match [regex]::Escape($OldId)) {
        $count = ([regex]::Matches($content, [regex]::Escape($OldId))).Count

        $newContent = $content -replace [regex]::Escape($OldId), $NewId

        [System.IO.File]::WriteAllText($filePath, $newContent, (New-Object System.Text.UTF8Encoding($false)))

        Write-Host "FIXED: $($_.Name) ($count replacements)" -ForegroundColor Green

        $script:TotalFiles++
        $script:TotalReplacements += $count
    }
}

Write-Host ""
Write-Host "========== DONE ==========" -ForegroundColor Cyan
Write-Host "Files changed: $TotalFiles, Total replacements: $TotalReplacements"

if ($TotalFiles -eq 0) {
    Write-Host "No old GA4 ID found in any file." -ForegroundColor Yellow
    Write-Host "This might mean the tag needs to be manually inserted instead of replaced." -ForegroundColor Yellow
}
