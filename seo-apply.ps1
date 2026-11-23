<#
  seo-apply.ps1  -  舒苑 SEO 一鍵整理
  在 repo 根目錄（看得到 CNAME 的資料夾）執行：
     powershell -ExecutionPolicy Bypass -File .\seo-apply.ps1
  只想預覽、不改任何檔案：
     powershell -ExecutionPolicy Bypass -File .\seo-apply.ps1 -DryRun

  做的事（每個會改檔案的步驟都會先問你 y/n）：
   1. 全站體檢（title / description / canonical / noindex / 重複），輸出 seo-audit.csv 到桌面
   2. 移除 6 篇部落格的 noindex
   3. 把仍是 noindex 的頁面從 sitemap.xml 拿掉
   4. 改 4 個頁面的 title / description（草稿在下方 $Edits，可先改成你要的字）
   5. 檢查內部連結並印出可貼上的連結
   6. git commit + push，等部署後用 IndexNow 送出有改的頁面
#>
param([switch]$DryRun)
$ErrorActionPreference = "Continue"
$utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path ".\CNAME")) { Write-Host "請在 repo 根目錄執行（要看得到 CNAME 檔）"; exit 1 }
if (-not (Test-Path ".\.git")) { Write-Host "這個資料夾不是 git repo，請到 2345-repo 資料夾執行"; exit 1 }

$Root   = (Get-Location).Path.TrimEnd('\')
$Domain = (Get-Content .\CNAME -Raw).Trim()
$Key    = "ba38550f53bf4777bcf39aa90020706c"

# ======== 可自行修改的設定 ========
$Unblock = @(
  "blog/how-we-select-ingredients.html",
  "blog/how-to-plan-a-dish.html",
  "blog/why-seasonal-ingredients-matter.html",
  "blog/why-balance-matters-in-a-dish.html",
  "blog/why-sweetness-balances-saltiness.html",
  "blog/what-does-searing-do.html"
)
$Edits = @(
  @{ File = "menu-banquet.html"
     Title = "辦桌菜單｜到府辦桌菜色與搭配建議｜舒苑私廚"
     Desc  = "辦桌菜單怎麼排？整理常見辦桌菜色與出菜順序，從前菜、湯品到主菜與甜點，提供到府辦桌與宴席菜單規劃，可依人數與場合客製。" },
  @{ File = "private-chef-taipei.html"
     Title = "台北私廚到府服務｜客製菜單・費用・流程｜舒苑"
     Desc  = "台北到府私廚服務，由主廚到府現場料理，依人數與場合客製菜單。了解服務流程、費用與案例，歡迎預約洽詢。" },
  @{ File = "blog/what-is-private-chef.html"
     Title = "私廚是什麼？到府私廚的費用、流程與適合場合｜舒苑"
     Desc  = "私廚是什麼？整理到府私廚與餐廳、外燴的差異，並說明服務流程、費用考量與適合的聚會場合，幫你快速決定。" },
  @{ File = "blog/what-is-tasting-menu.html"
     Title = "無菜單料理是什麼？Tasting Menu 特色與出菜流程｜舒苑"
     Desc  = "無菜單料理是什麼？認識 Tasting Menu 的定義、出菜順序與適合場合，以及在家也能享受的到府主廚料理。" }
)
# ==================================

# ---------- 工具函式 ----------
function Read-Text([string]$p)  { return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Text([string]$p, [string]$t) { if (-not $DryRun) { [System.IO.File]::WriteAllText($p, $t, $utf8) } }
function To-Path([string]$rel)  { return (Join-Path $Root ($rel -replace '/', '\')) }
function To-Url([string]$rel)   { $p = $rel -replace '(^|/)index\.html$', '$1'; return "https://$Domain/$p" }
function Esc-Html([string]$s)   { return $s.Replace('&','&amp;').Replace('"','&quot;').Replace('<','&lt;') }
function Ask([string]$q)        { $a = Read-Host "$q (y/n)"; return ($a -match '^[yY]') }

function Get-MetaTags([string]$t) { return @([regex]::Matches($t, '(?is)<meta\b[^>]*>') | ForEach-Object { $_.Value }) }
function Is-RobotsNoindex([string]$tag) {
  return (($tag -match '(?is)\bname\s*=\s*["''](robots|googlebot)["'']') -and ($tag -match '(?i)noindex'))
}
function Get-NoindexTags([string]$t) { return @(Get-MetaTags $t | Where-Object { Is-RobotsNoindex $_ }) }

function Remove-Noindex([string]$t) {
  $sb = { param($m) if (Is-RobotsNoindex $m.Value) { '' } else { $m.Value } }
  $ev = [System.Text.RegularExpressions.MatchEvaluator]$sb
  return [regex]::Replace($t, '(?is)[ \t]*<meta\b[^>]*>[ \t]*\r?\n?', $ev)
}

function Set-Title([string]$html, [string]$new) {
  $esc = Esc-Html $new
  $sb = { param($m) $m.Groups[1].Value + $esc + $m.Groups[3].Value }.GetNewClosure()
  $ev = [System.Text.RegularExpressions.MatchEvaluator]$sb
  $r = New-Object System.Text.RegularExpressions.Regex('(?is)(<title[^>]*>)(.*?)(</title>)')
  return $r.Replace($html, $ev, 1)
}

# 改 <meta name="description"> 或 <meta property="og:title"> 這類標籤的 content；找不到回傳原文
function Set-MetaContent([string]$html, [string]$attr, [string]$new) {
  $esc = Esc-Html $new
  $pat = '(?is)<meta\b[^>]*\b(?:name|property)\s*=\s*["'']' + [regex]::Escape($attr) + '["''][^>]*>'
  $inner = { param($c) $c.Groups[1].Value + '"' + $esc + '"' }.GetNewClosure()
  $innerEv = [System.Text.RegularExpressions.MatchEvaluator]$inner
  $outer = { param($m) [regex]::Replace($m.Value, '(?is)(\bcontent\s*=\s*)(["''])(.*?)\2', $innerEv) }.GetNewClosure()
  $outerEv = [System.Text.RegularExpressions.MatchEvaluator]$outer
  $r = New-Object System.Text.RegularExpressions.Regex($pat)
  return $r.Replace($html, $outerEv, 1)
}
function Has-Meta([string]$html, [string]$attr) {
  return [regex]::IsMatch($html, '(?is)<meta\b[^>]*\b(?:name|property)\s*=\s*["'']' + [regex]::Escape($attr) + '["'']')
}

function Get-Title([string]$t) { $m = [regex]::Match($t, '(?is)<title[^>]*>(.*?)</title>'); if ($m.Success) { return $m.Groups[1].Value.Trim() } else { return "" } }
function Get-MetaContent([string]$t, [string]$attr) {
  foreach ($tag in (Get-MetaTags $t)) {
    if ($tag -match ('(?is)\b(?:name|property)\s*=\s*["'']' + [regex]::Escape($attr) + '["'']')) {
      $m = [regex]::Match($tag, '(?is)\bcontent\s*=\s*(["''])(.*?)\1')
      if ($m.Success) { return $m.Groups[2].Value.Trim() }
    }
  }
  return ""
}
function Get-Canonical([string]$t) {
  foreach ($m in [regex]::Matches($t, '(?is)<link\b[^>]*>')) {
    if ($m.Value -match '(?is)\brel\s*=\s*["'']canonical["'']') {
      $h = [regex]::Match($m.Value, '(?is)\bhref\s*=\s*(["''])(.*?)\1')
      if ($h.Success) { return $h.Groups[2].Value.Trim() }
    }
  }
  return ""
}

$Changed = New-Object System.Collections.Generic.List[string]
function Mark-Changed([string]$rel) { if (-not $Changed.Contains($rel)) { [void]$Changed.Add($rel) } }

if ($DryRun) { Write-Host "【預覽模式】不會修改任何檔案、不會 commit 或送出" -ForegroundColor Yellow }

# ---------- 0. 同步 ----------
Write-Host "`n[0] 同步最新版本 (git pull)" -ForegroundColor Cyan
git pull
$dirty = git status --porcelain
if ($dirty) { Write-Host "提醒：目前有尚未 commit 的變更，本腳本只會 commit 它自己改的檔案。" -ForegroundColor Yellow }

# ---------- 1. 全站體檢 ----------
Write-Host "`n[1] 全站體檢" -ForegroundColor Cyan
$files = Get-ChildItem -Path $Root -Recurse -Filter *.html -File | Where-Object { $_.FullName -notmatch '\\(\.git|node_modules)\\' }
$rows = foreach ($f in $files) {
  $rel = ($f.FullName.Substring($Root.Length).TrimStart('\') -replace '\\', '/')
  $t = Read-Text $f.FullName
  $title = Get-Title $t
  $desc  = Get-MetaContent $t 'description'
  $canon = Get-Canonical $t
  $exp   = To-Url $rel
  [pscustomobject]@{
    File = $rel; Title = $title; TitleLen = $title.Length
    DescLen = $desc.Length; Canonical = $canon
    CanonicalOK = ($canon -eq $exp)
    Noindex = ((Get-NoindexTags $t).Count -gt 0)
    Description = $desc
  }
}
$report = Join-Path ([Environment]::GetFolderPath('Desktop')) "seo-audit.csv"
$rows | Export-Csv -Path $report -NoTypeInformation -Encoding UTF8

$real = $rows | Where-Object { $_.File -ne '404.html' }
Write-Host ("頁面總數：{0}" -f $real.Count)
Write-Host ("缺 title：{0}" -f @($real | Where-Object { $_.TitleLen -eq 0 }).Count)
Write-Host ("title 過長(>35字)：{0}" -f @($real | Where-Object { $_.TitleLen -gt 35 }).Count)
Write-Host ("缺 description：{0}" -f @($real | Where-Object { $_.DescLen -eq 0 }).Count)
Write-Host ("description 過短(<40字)或過長(>110字)：{0}" -f @($real | Where-Object { $_.DescLen -gt 0 -and ($_.DescLen -lt 40 -or $_.DescLen -gt 110) }).Count)
Write-Host ("canonical 缺少或與預期網址不同：{0}" -f @($real | Where-Object { -not $_.CanonicalOK }).Count)
Write-Host ("目前是 noindex 的頁面：{0}" -f @($real | Where-Object { $_.Noindex }).Count)
$dupT = $real | Where-Object { $_.Title } | Group-Object Title | Where-Object { $_.Count -gt 1 }
Write-Host ("重複的 title 組數：{0}" -f @($dupT).Count)
Write-Host "完整報表已存到：$report" -ForegroundColor Green

# ---------- 2. 移除 6 篇部落格的 noindex ----------
Write-Host "`n[2] 移除指定部落格的 noindex" -ForegroundColor Cyan
$toFix = @()
foreach ($rel in $Unblock) {
  $p = To-Path $rel
  if (-not (Test-Path $p)) { Write-Host "找不到：$rel" -ForegroundColor Yellow; continue }
  $tags = Get-NoindexTags (Read-Text $p)
  if ($tags.Count -eq 0) { Write-Host "已無 noindex：$rel"; continue }
  Write-Host "$rel  →  $($tags -join ' ')"
  $toFix += $rel
}
if ($toFix.Count -gt 0 -and (Ask "移除以上 $($toFix.Count) 頁的 noindex？")) {
  foreach ($rel in $toFix) {
    $p = To-Path $rel
    Write-Text $p (Remove-Noindex (Read-Text $p))
    Mark-Changed $rel
  }
  Write-Host "完成" -ForegroundColor Green
}

# ---------- 3. sitemap 清理 ----------
Write-Host "`n[3] 檢查 sitemap.xml 裡有沒有仍是 noindex 的頁面" -ForegroundColor Cyan
$smPath = To-Path "sitemap.xml"
if (Test-Path $smPath) {
  $sm = Read-Text $smPath
  $bad = @()
  foreach ($m in [regex]::Matches($sm, '(?is)<loc>\s*(.*?)\s*</loc>')) {
    $loc = $m.Groups[1].Value
    $rel = [uri]::UnescapeDataString(($loc -replace '^https?://[^/]+/?', ''))
    if ($rel -eq '' -or $rel.EndsWith('/')) { $rel = $rel + 'index.html' }
    $p = To-Path $rel
    if ((Test-Path $p) -and ($rel -like '*.html')) {
      if ((Get-NoindexTags (Read-Text $p)).Count -gt 0) { $bad += [pscustomobject]@{ Loc = $loc; Rel = $rel } }
    }
  }
  if (@($bad).Count -eq 0) { Write-Host "sitemap 裡沒有 noindex 頁面，OK" -ForegroundColor Green }
  else {
    $bad | ForEach-Object { Write-Host "  $($_.Loc)" }
    if (Ask "把以上 $(@($bad).Count) 個網址從 sitemap.xml 移除？") {
      foreach ($b in $bad) {
        $pat = '(?is)[ \t]*<url>\s*<loc>\s*' + [regex]::Escape($b.Loc) + '\s*</loc>.*?</url>[ \t]*\r?\n?'
        $sm = [regex]::Replace($sm, $pat, '')
      }
      Write-Text $smPath $sm
      Mark-Changed "sitemap.xml"
      Write-Host "完成" -ForegroundColor Green
    }
  }
} else { Write-Host "找不到 sitemap.xml" -ForegroundColor Yellow }

# ---------- 4. 改 title / description ----------
Write-Host "`n[4] 改標題與描述" -ForegroundColor Cyan
$plan = @()
foreach ($e in $Edits) {
  $p = To-Path $e.File
  if (-not (Test-Path $p)) { Write-Host "找不到：$($e.File)" -ForegroundColor Yellow; continue }
  $t = Read-Text $p
  Write-Host "`n■ $($e.File)"
  Write-Host "  原 title：$(Get-Title $t)"
  Write-Host "  新 title：$($e.Title)" -ForegroundColor Green
  Write-Host "  原 desc ：$(Get-MetaContent $t 'description')"
  Write-Host "  新 desc ：$($e.Desc)" -ForegroundColor Green
  $plan += $e
}
if ($plan.Count -gt 0 -and (Ask "`n套用以上全部修改？（想改字請 n，先編輯腳本上方的 `$Edits 再重跑）")) {
  foreach ($e in $plan) {
    $p = To-Path $e.File
    $t = Read-Text $p
    $t = Set-Title $t $e.Title
    if (Has-Meta $t 'description') { $t = Set-MetaContent $t 'description' $e.Desc }
    else {
      $ins = '$0' + "`r`n" + '<meta name="description" content="' + (Esc-Html $e.Desc) + '">'
      $rt = New-Object System.Text.RegularExpressions.Regex('(?i)</title>')
      $t = $rt.Replace($t, $ins, 1)
    }
    if (Has-Meta $t 'og:title')       { $t = Set-MetaContent $t 'og:title' $e.Title }
    if (Has-Meta $t 'og:description') { $t = Set-MetaContent $t 'og:description' $e.Desc }
    if (Has-Meta $t 'twitter:title')       { $t = Set-MetaContent $t 'twitter:title' $e.Title }
    if (Has-Meta $t 'twitter:description') { $t = Set-MetaContent $t 'twitter:description' $e.Desc }
    Write-Text $p $t
    Mark-Changed $e.File
  }
  Write-Host "完成" -ForegroundColor Green
}

# ---------- 5. 內部連結檢查 ----------
Write-Host "`n[5] 內部連結檢查" -ForegroundColor Cyan
$linkTargets = @(
  @{ From = "blog/taipei-private-chef-guide.html"; To = "private-chef-taipei.html"; Text = "台北私廚到府服務" },
  @{ From = "index.html"; To = "private-chef-taipei.html"; Text = "台北私廚到府服務" },
  @{ From = "private-chef.html"; To = "private-chef-taipei.html"; Text = "台北私廚到府服務" }
)
foreach ($l in $linkTargets) {
  $p = To-Path $l.From
  if (-not (Test-Path $p)) { Write-Host "找不到：$($l.From)" -ForegroundColor Yellow; continue }
  $t = Read-Text $p
  if ($t -match [regex]::Escape($l.To)) { Write-Host "OK  $($l.From) 已連到 $($l.To)" -ForegroundColor Green }
  else {
    Write-Host "缺  $($l.From) 沒有連到 $($l.To)，可貼在內文適當位置：" -ForegroundColor Yellow
    Write-Host ('    <a href="/' + $l.To + '">' + $l.Text + '</a>')
  }
}

# ---------- 6. commit / push / IndexNow ----------
Write-Host "`n[6] 發佈" -ForegroundColor Cyan
if ($Changed.Count -eq 0) { Write-Host "這次沒有修改任何檔案，結束。"; exit 0 }
Write-Host "這次修改的檔案："; $Changed | ForEach-Object { Write-Host "  $_" }
if ($DryRun) { Write-Host "【預覽模式】到此為止。" -ForegroundColor Yellow; exit 0 }
if (-not (Ask "commit 並 push 到 GitHub？")) { Write-Host "已取消（檔案已修改但尚未 commit）"; exit 0 }

foreach ($rel in $Changed) { git add -- $rel }
git commit -m "SEO：移除部落格 noindex、清理 sitemap、優化標題與描述"
git push
if ($LASTEXITCODE -ne 0) { Write-Host "git push 失敗，請把上面的錯誤貼給我" -ForegroundColor Red; exit 1 }

$pages = @($Changed | Where-Object { $_ -like '*.html' -and $_ -ne '404.html' })
if ($pages.Count -eq 0) { Write-Host "沒有需要送 IndexNow 的頁面。"; exit 0 }
if (-not (Ask "等網站部署完（約 90 秒）後，用 IndexNow 送出 $($pages.Count) 個頁面？")) { exit 0 }
Write-Host "等待部署 90 秒..."; Start-Sleep -Seconds 90

$urls = @($pages | ForEach-Object { To-Url $_ })
$body = @{ host = $Domain; key = $Key; keyLocation = "https://$Domain/$Key.txt"; urlList = $urls } | ConvertTo-Json
foreach ($ep in @("https://api.indexnow.org/IndexNow", "https://www.bing.com/indexnow")) {
  try {
    $r = Invoke-WebRequest -Uri $ep -Method Post -ContentType "application/json; charset=utf-8" -Body $body -UseBasicParsing
    Write-Host "$ep → $($r.StatusCode)" -ForegroundColor Green
  } catch {
    $code = ""; try { $code = $_.Exception.Response.StatusCode.value__ } catch {}
    Write-Host "$ep → 失敗 $code" -ForegroundColor Yellow
  }
}
Write-Host "`n全部完成。" -ForegroundColor Green
