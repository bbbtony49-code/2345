# Batch replace www.shuyuan-chef.com -> shuyuan-chef.com in all html/xml/txt files
# Usage:
#   1. Put this file in the repo folder (same folder as areas-taoyuan.html)
#   2. Open PowerShell in that folder (Shift + right click -> Open PowerShell window here)
#   3. Run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   4. Run: .\fix_domain.ps1

$OldDomain = "www.shuyuan-chef.com"
$NewDomain = "shuyuan-chef.com"
$Extensions = @("*.html", "*.htm", "*.xml", "*.txt")

$TotalFiles = 0
$TotalReplacements = 0

Write-Host "Scanning..." -ForegroundColor Cyan

Get-ChildItem -Path . -Recurse -Include $Extensions -File | Where-Object {
    $_.FullName -notmatch '\\\.git\\'
} | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content -Path $filePath -Raw -Encoding UTF8

    if ($content -match [regex]::Escape($OldDomain)) {
        $count = ([regex]::Matches($content, [regex]::Escape($OldDomain))).Count

        $newContent = $content -replace [regex]::Escape("https://$OldDomain"), "https://$NewDomain"
        $newContent = $newContent -replace [regex]::Escape("http://$OldDomain"), "https://$NewDomain"
        $newContent = $newContent -replace [regex]::Escape($OldDomain), $NewDomain

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
    Write-Host "No leftover www version found. Might already be clean!" -ForegroundColor Yellow
}
