# ============================================
# SHUYUAN Website Deploy Script
# Usage: put this file together with index.html,
# css folder, and en folder into your repo folder,
# then run in PowerShell:
#   .\deploy.ps1
# ============================================

# 1. Check we're in a git repo root
if (-not (Test-Path ".git")) {
    Write-Host "ERROR: This is not a git repo root. Please cd into your 2345 project folder first." -ForegroundColor Red
    exit
}

# 2. Create en folder if missing
if (-not (Test-Path "en")) {
    New-Item -ItemType Directory -Path "en" | Out-Null
    Write-Host "Created en folder" -ForegroundColor Green
}

# 3. Confirm files are in place
Write-Host ""
Write-Host "Please confirm these files are already in place:" -ForegroundColor Yellow
Write-Host "  - index.html        (repo root, Chinese homepage)"
Write-Host "  - css\style.css      (overwrites existing css/style.css)"
Write-Host "  - en\index.html      (new English homepage)"
Write-Host ""
$confirm = Read-Host "Are all files in place? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Please copy the files into place first, then run this script again." -ForegroundColor Yellow
    exit
}

# 4. Git add (all updated html pages + css + en homepage)
git add *.html
git add blog/*.html
git add css/style.css
git add en/index.html

# 5. Show status
Write-Host ""
Write-Host "The following changes will be committed:" -ForegroundColor Cyan
git status

# 6. Commit
$commitMsg = "Homepage brand upgrade: story section + bilingual switch"
git commit -m $commitMsg

# 7. Push
Write-Host ""
Write-Host "Pushing to GitHub main branch..." -ForegroundColor Cyan
git push origin main

Write-Host ""
Write-Host "Done! The site should update in a few minutes." -ForegroundColor Green
