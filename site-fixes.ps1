<#
  site-fixes.ps1  -  舒苑網站「非標題」問題一次處理
  在 repo 根目錄（看得到 CNAME 的資料夾）執行：
     powershell -ExecutionPolicy Bypass -File .\site-fixes.ps1 -DryRun   (只預覽，不改檔)
     powershell -ExecutionPolicy Bypass -File .\site-fixes.ps1           (正式執行，每個步驟都會問 y/n)

  不會動任何頁面的 title / description。處理內容：
   1. menu-banquet.html 加上 LINE、電話行動呼籲區塊
   2. what-is-tasting-menu.html 補一句「無菜單料理的英文」
   3. 統一「最低預約人數」說法（首頁與台北頁）
   4. 首頁：刪除兩句給搜尋引擎看的話
   5. 首頁服務卡片、菜單卡片、全站頁尾：連到對應的專頁
   6. 全站：/index.html 連結統一成 /（blog、en 也一樣）
   7. 全站：移除已被 Google 忽略的 meta keywords
   8. sitemap.xml：移除仍是 noindex 的頁面
   9. 首頁地圖：貼上你的商家嵌入網址後才會換（見下方 $MapEmbedSrc）
  10. 只回報不修改：「全台唯一」用語、其他頁面的最低人數說法
  最後 commit + push，並用 IndexNow 送出有內容變動的主要頁面。
#>
param([switch]$DryRun, [switch]$Yes)
$ErrorActionPreference = "Continue"

# ======== 可自行修改的設定 ========
$MapEmbedSrc = ""   # 例：Google 地圖 → 你的商家 → 分享 → 嵌入地圖 → 複製 iframe 裡 src="..." 的網址，貼在這裡
$Key = "ba38550f53bf4777bcf39aa90020706c"
$LineUrl = "https://lin.ee/Tns33CH"
$Phone = "0911247783"; $PhoneShow = "0911-247-783"

# 首頁服務卡片／菜單卡片：用卡片上獨有的一句話找到卡片，把連結改到對應專頁
$CardLinks = @(
  @{ Phrase = "尾牙、春酒、品牌發表會與商務宴客";          File = "corporate-catering-cases.html" },
  @{ Phrase = "董事長宴請、政商接待、私人遊艇宴會";        File = "vip-banquet-cases.html" },
  @{ Phrase = "在豪宅內打造尊榮家宴";                      File = "family-banquet-luxury.html" },
  @{ Phrase = "高端茶點與甜品設計，適合精品茶會與小型 VIP 聚會"; File = "pricing-afternoontea.html" },
  @{ Phrase = "適合 6-10 人的私密聚餐";                    File = "menu-2-8.html" },
  @{ Phrase = "高端茶點與甜品設計，適合精品下午茶與小型 VIP 聚會"; File = "pricing-afternoontea.html" },
  @{ Phrase = "傳統中式辦桌與外燴現場服務";                File = "menu-banquet.html" }
)
# 全站頁尾（<footer> 內）連結文字 → 專頁
$FooterLinks = @{ "企業外燴" = "corporate-catering-cases.html"; "VIP 餐宴" = "vip-banquet-cases.html"; "豪宅家宴" = "family-banquet-luxury.html" }
# 要刪除的「給搜尋引擎看的話」
$SeoSentences = @(
  "每一個服務類別都是我們主題權威的分支，並且彼此串連成完整的到府私廚生態。",
  "我們不是一般公司網站，而是把每個服務做成一個專業、可信的完整頁面。"
)
# 要統一的人數說法：{ 檔案, 原句, 新句 }
$TextFixes = @(
  @{ File = "index.html";
     Old = "建議 6-8 人以上以確保服務品質與客製化菜單的完整性。";
     New = "最少 2 人即可預約規劃，建議 6-8 人以上以確保服務品質與客製化菜單的完整性。" },
  @{ File = "private-chef-taipei.html";
     Old = "從 2 人小型家宴到 30 人企業接待皆可規劃，實際起價依人數與菜色而定，歡迎先提供人數與日期詢問。";
     New = "從 2 人小型家宴到 30 人企業接待皆可規劃，建議 6–8 人以上更能發揮客製化菜單的完整性；實際起價依人數與菜色而定，歡迎先提供人數與日期詢問。" },
  @{ File = "private-chef-taipei.html";
     Old = "最後更新：2026 年 10 月 11 日";
     New = "最後更新：2026 年 10 月 13 日" }
)
# ==================================

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
if (-not (Test-Path "./CNAME")) { Write-Host "請在 repo 根目錄執行（要看得到 CNAME 檔）"; exit 1 }
if (-not (Test-Path "./.git")) { Write-Host "這個資料夾不是 git repo，請到 2345-repo 資料夾執行"; exit 1 }
$Root = (Get-Location).Path.TrimEnd('\','/')
$Domain = (Get-Content ./CNAME -Raw).Trim()
if ($DryRun) { Write-Host "【預覽模式】不會修改任何檔案" -ForegroundColor Yellow }

# ---------- 工具函式 ----------
function Read-Text([string]$p) { return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Text([string]$p, [string]$t) {
  if ($DryRun) { return }
  $bom = $false
  $b = [System.IO.File]::ReadAllBytes($p)
  if ($b.Length -ge 3 -and $b[0] -eq 0xEF -and $b[1] -eq 0xBB -and $b[2] -eq 0xBF) { $bom = $true }
  [System.IO.File]::WriteAllText($p, $t, (New-Object System.Text.UTF8Encoding($bom)))
}
function To-Path([string]$rel) { return (Join-Path $Root $rel) }
function Done { if ($DryRun) { Write-Host "完成（預覽，未寫入）" -ForegroundColor Green } else { Write-Host "完成" -ForegroundColor Green } }
function Ask([string]$q) {
  if ($Yes) { Write-Host "$q (y/n) → y"; return $true }
  $a = Read-Host "$q (y/n)"; return ($a -match '^[yY]')
}
function Snip([string]$s, [int]$n) { $s = ($s -replace '\s+', ' ').Trim(); if ($s.Length -gt $n) { return $s.Substring(0, $n) + "…" } else { return $s } }

# 用 pattern 找出每個符合處，交給 scriptblock 決定要換成什麼字
function Replace-Regex([string]$text, [string]$pattern, [scriptblock]$fn) {
  $ms = [regex]::Matches($text, $pattern)
  if ($ms.Count -eq 0) { return $text }
  $sb = New-Object System.Text.StringBuilder
  $last = 0
  foreach ($m in $ms) {
    [void]$sb.Append($text.Substring($last, $m.Index - $last))
    $r = & $fn $m
    [void]$sb.Append([string]$r)
    $last = $m.Index + $m.Length
  }
  [void]$sb.Append($text.Substring($last))
  return $sb.ToString()
}
function Count-Of([string]$text, [string]$needle) { return ([regex]::Matches($text, [regex]::Escape($needle))).Count }

# 把 <a ...> 屬性裡 href 指到的 .html 檔名換成 $file（保留資料夾前綴與 #錨點）
function Set-HrefFile([string]$attrs, [string]$file) {
  return (Replace-Regex $attrs '(?is)(\bhref\s*=\s*)(["''])([^"'']*)\2' {
    param($m)
    $v = $m.Groups[3].Value
    $mm = [regex]::Match($v, '^(.*?)([^/#?]+\.html)([?#].*)?$')
    if ($mm.Success) {
      $nv = $mm.Groups[1].Value + $file + $mm.Groups[3].Value
      return ($m.Groups[1].Value + $m.Groups[2].Value + $nv + $m.Groups[2].Value)
    }
    return $m.Value
  })
}

# 首頁 /index.html、/blog/index.html、/en/index.html → /、/blog/、/en/
function Norm-Href([string]$v, [string]$dir) {
  $mm = [regex]::Match($v, '^(?<pre>https?://[^/]+)?(?<path>[^?#]*)(?<suf>[?#].*)?$')
  if (-not $mm.Success) { return $v }
  $pre = $mm.Groups['pre'].Value; $path = $mm.Groups['path'].Value; $suf = $mm.Groups['suf'].Value
  if ($pre -ne "") {
    $h = ($pre -replace '^https?://', '').ToLower()
    if ($h -ne $Domain.ToLower() -and $h -ne ("www." + $Domain.ToLower())) { return $v }
  }
  if ($path.StartsWith('/')) { $abs = $path }
  elseif ($path.StartsWith('../')) { $abs = '/' + $path.Substring(3) }
  elseif ($path -match '^(\.|[a-z]+:)') { return $v }
  else { if ($dir -eq '') { $abs = '/' + $path } else { $abs = '/' + $dir + '/' + $path } }
  $new = $null
  if ($abs -eq '/index.html') { $new = '/' }
  elseif ($abs -match '^/(blog|en)/index\.html$') { $new = '/' + $Matches[1] + '/' }
  if ($null -eq $new) { return $v }
  return ($pre + $new + $suf)
}

# ---------- 全站處理：每一頁跑一次 ----------
function Invoke-Sitewide([string]$rel, [string]$t, [hashtable]$opt, [hashtable]$cnt) {
  $dir = ''
  if ($rel.Contains('/')) { $dir = $rel.Substring(0, $rel.LastIndexOf('/')) }

  if ($opt.Index) {
    $t = Replace-Regex $t '(?is)<a\b[^>]*>' {
      param($m)
      $tag = Replace-Regex $m.Value '(?is)(\bhref\s*=\s*)(["''])([^"'']*)\2' {
        param($h)
        $nv = Norm-Href $h.Groups[3].Value $dir
        if ($nv -ne $h.Groups[3].Value) { $cnt.Index++ }
        return ($h.Groups[1].Value + $h.Groups[2].Value + $nv + $h.Groups[2].Value)
      }
      return $tag
    }
  }
  if ($opt.Keywords) {
    $before = $t
    $t = [regex]::Replace($t, '(?is)[ \t]*<meta\b[^>]*\bname\s*=\s*["'']keywords["''][^>]*>[ \t]*\r?\n?', '')
    if ($t -ne $before) { $cnt.Keywords++ }
  }
  if ($opt.Seo) {
    foreach ($s in $SeoSentences) {
      if ($t.Contains($s)) {
        $pat = '(?is)[ \t]*<p\b[^>]*>\s*' + [regex]::Escape($s) + '\s*</p>[ \t]*\r?\n?'
        $n = ([regex]::Matches($t, $pat)).Count
        if ($n -gt 0) { $t = [regex]::Replace($t, $pat, ''); $cnt.Seo += $n }
        else { $t = $t.Replace($s, ''); $cnt.Seo++ }
      }
    }
  }
  if ($opt.Footer) {
    $fm = [regex]::Match($t, '(?is)<footer\b.*?</footer>')
    if ($fm.Success) {
      $foot = Replace-Regex $fm.Value '(?is)<a\b([^>]*)>(.*?)</a>' {
        param($a)
        $inner = ([regex]::Replace($a.Groups[2].Value, '<[^>]+>', '')).Trim()
        if ($FooterLinks.ContainsKey($inner) -and $FooterFilesOk[$FooterLinks[$inner]]) {
          $na = Set-HrefFile $a.Groups[1].Value $FooterLinks[$inner]
          if ($na -ne $a.Groups[1].Value) { $cnt.Footer++ }
          return ('<a' + $na + '>' + $a.Groups[2].Value + '</a>')
        }
        return $a.Value
      }
      if ($foot -ne $fm.Value) { $t = $t.Substring(0, $fm.Index) + $foot + $t.Substring($fm.Index + $fm.Length) }
    }
  }
  return $t
}

# ---------- 0. 同步 ----------
Write-Host "`n[0] 同步最新版本 (git pull)" -ForegroundColor Cyan
git pull
$dirty = git status --porcelain
if ($dirty) { Write-Host "提醒：目前有尚未 commit 的變更，本腳本只會 commit 它自己改的檔案。" -ForegroundColor Yellow }

$files = Get-ChildItem -Path $Root -Recurse -File -Filter *.html | Where-Object { $_.FullName -notmatch '[\\/](\.git|node_modules)[\\/]' }
$rels = @{}
foreach ($f in $files) { $r = ($f.FullName.Substring($Root.Length).TrimStart('\','/') -replace '\\', '/'); $rels[$r] = $f.FullName }
Write-Host ("找到 {0} 個 HTML 頁面" -f $rels.Count)

$FooterFilesOk = @{}
foreach ($v in $FooterLinks.Values) { $FooterFilesOk[$v] = $rels.ContainsKey($v) }
foreach ($k in $FooterFilesOk.Keys) { if (-not $FooterFilesOk[$k]) { Write-Host "注意：找不到 $k，相關頁尾連結不會修改" -ForegroundColor Yellow } }

$Changed = New-Object System.Collections.Generic.List[string]
$Content = New-Object System.Collections.Generic.List[string]   # 有內容變動、要送 IndexNow 的頁面
function Mark([string]$rel, [bool]$isContent) {
  if (-not $Changed.Contains($rel)) { [void]$Changed.Add($rel) }
  if ($isContent -and -not $Content.Contains($rel)) { [void]$Content.Add($rel) }
}

# ---------- 1. menu-banquet 行動呼籲 ----------
Write-Host "`n[1] menu-banquet.html：加入 LINE、電話行動呼籲區塊" -ForegroundColor Cyan
$ctaHtml = @"
<section class="banquet-cta" aria-label="預約諮詢">
<style>
.banquet-cta{max-width:880px;margin:3rem auto;padding:2rem 1.5rem;text-align:center;border:1px solid #D4AF37;border-radius:12px;background:rgba(212,175,55,.08)}
.banquet-cta h2{margin:0 0 .6rem;font-size:1.4rem}
.banquet-cta p{margin:0 0 1.2rem;opacity:.9}
.banquet-cta .cta-row{display:flex;flex-wrap:wrap;gap:.8rem;justify-content:center}
.banquet-cta a{display:inline-block;padding:.8rem 1.6rem;border-radius:999px;border:1px solid #D4AF37;text-decoration:none;font-weight:600}
.banquet-cta a.cta-primary{background:#D4AF37;color:#111}
.banquet-cta a.cta-secondary{color:inherit}
</style>
<h2>想把這份菜單排進您的場合？</h2>
<p>告訴我們人數、日期與場地，主廚團隊 24 小時內回覆專屬菜單與報價。</p>
<div class="cta-row">
<a class="cta-primary" href="$LineUrl" target="_blank" rel="noopener" onclick="return typeof gtag_report_conversion_line==='function'?gtag_report_conversion_line('$LineUrl'):true;">💬 LINE 免費索取菜單與報價</a>
<a class="cta-secondary" href="tel:$Phone" onclick="return typeof gtag_report_conversion_phone==='function'?gtag_report_conversion_phone('tel:$Phone'):true;">📞 $PhoneShow</a>
</div>
</section>

"@
$rel = "menu-banquet.html"
if (-not $rels.ContainsKey($rel)) { Write-Host "找不到 $rel，略過" -ForegroundColor Yellow }
else {
  $t = Read-Text $rels[$rel]
  if ($t.Contains('class="banquet-cta"')) { Write-Host "已經有這個區塊，略過" }
  else {
    $mm = [regex]::Match($t, '(?is)</main>')
    $where = "</main> 之前"
    if (-not $mm.Success) { $mm = [regex]::Match($t, '(?is)<footer\b'); $where = "<footer> 之前" }
    if (-not $mm.Success) { Write-Host "找不到 </main> 或 <footer>，略過（請把頁面結構貼給我）" -ForegroundColor Yellow }
    else {
      $ctx = Snip $t.Substring([Math]::Max(0, $mm.Index - 120), [Math]::Min(120, $mm.Index)) 100
      Write-Host "會插入在 $where，前面的內容是：$ctx"
      if (Ask "加入 LINE、電話區塊？") {
        $nl = "`n"; if ($t.Contains("`r`n")) { $nl = "`r`n"; $ins = $ctaHtml.Replace("`r`n", "`n").Replace("`n", "`r`n") } else { $ins = $ctaHtml.Replace("`r`n", "`n") }
        $t = $t.Insert($mm.Index, $ins)
        Write-Text $rels[$rel] $t; Mark $rel $true; Done
      }
    }
  }
}

# ---------- 2. 無菜單料理：補英文說法 ----------
Write-Host "`n[2] what-is-tasting-menu.html：補一句「無菜單料理的英文」" -ForegroundColor Cyan
$rel = "blog/what-is-tasting-menu.html"
$enSentence = "<p>無菜單料理的英文常見說法有兩種：日式稱 Omakase（お任せ，意指「交給主廚決定」），西式與高級餐廳多稱 Tasting Menu（主廚品嚐菜單）。</p>"
if (-not $rels.ContainsKey($rel)) { Write-Host "找不到 $rel，略過" -ForegroundColor Yellow }
else {
  $t = Read-Text $rels[$rel]
  if ($t.Contains('Omakase（お任せ')) { Write-Host "已經有這句，略過" }
  else {
    $h1 = [regex]::Match($t, '(?is)</h1>')
    if (-not $h1.Success) { Write-Host "找不到 </h1>，略過" -ForegroundColor Yellow }
    else {
      $p = [regex]::Match($t.Substring($h1.Index + $h1.Length), '(?is)<p\b[^>]*>.*?</p>')
      if (-not $p.Success) { Write-Host "標題後找不到段落，略過" -ForegroundColor Yellow }
      else {
        $at = $h1.Index + $h1.Length + $p.Index + $p.Length
        Write-Host ("會插入在這一段之後：{0}" -f (Snip ([regex]::Replace($p.Value, '<[^>]+>', '')) 90))
        Write-Host ("插入內容：{0}" -f ([regex]::Replace($enSentence, '<[^>]+>', '')))
        if (Ask "加入這一句？") {
          $nl = "`n"; if ($t.Contains("`r`n")) { $nl = "`r`n" }
          $t = $t.Insert($at, $nl + $enSentence)
          Write-Text $rels[$rel] $t; Mark $rel $true; Done
        }
      }
    }
  }
}

# ---------- 3. 統一最低預約人數說法 ----------
Write-Host "`n[3] 統一「最低預約人數」說法" -ForegroundColor Cyan
$fixPlan = @()
foreach ($x in $TextFixes) {
  if (-not $rels.ContainsKey($x.File)) { Write-Host "找不到 $($x.File)" -ForegroundColor Yellow; continue }
  $t = Read-Text $rels[$x.File]
  if ($x.New.Contains($x.Old) -and $t.Contains($x.New)) { Write-Host "$($x.File)：已是新說法，略過"; continue }
  $n = Count-Of $t $x.Old
  if ($n -eq 0) { Write-Host "$($x.File)：找不到原句「$(Snip $x.Old 30)」（可能已改過或寫法不同）" -ForegroundColor Yellow; continue }
  Write-Host "■ $($x.File)（$n 處，含結構化資料裡的同一句）"
  Write-Host "  原：$($x.Old)"
  Write-Host "  新：$($x.New)" -ForegroundColor Green
  $fixPlan += $x
}
if ($fixPlan.Count -gt 0 -and (Ask "套用以上說法修改？")) {
  foreach ($x in $fixPlan) {
    $t = Read-Text $rels[$x.File]
    $t = $t.Replace($x.Old, $x.New)
    Write-Text $rels[$x.File] $t; Mark $x.File $true
  }
  Done
}

# ---------- 4. 首頁卡片連結 ----------
Write-Host "`n[4] 首頁服務卡片、菜單卡片：連到對應專頁" -ForegroundColor Cyan
$rel = "index.html"
if (-not $rels.ContainsKey($rel)) { Write-Host "找不到 index.html，略過" -ForegroundColor Yellow }
else {
  $t0 = Read-Text $rels[$rel]; $t = $t0; $cardPlan = 0
  foreach ($c in $CardLinks) {
    if (-not $rels.ContainsKey($c.File)) { Write-Host "找不到 $($c.File)，略過該卡片" -ForegroundColor Yellow; continue }
    $pat = '(?is)<a\b[^>]*>(?:(?!</a>).)*?' + [regex]::Escape($c.Phrase) + '(?:(?!</a>).)*?</a>'
    $tt = $t
    $t = Replace-Regex $t $pat {
      param($m)
      $open = [regex]::Match($m.Value, '(?is)^<a\b([^>]*)>')
      $na = Set-HrefFile $open.Groups[1].Value $c.File
      return ('<a' + $na + '>' + $m.Value.Substring($open.Length))
    }
    if ($t -ne $tt) { Write-Host ("  「{0}」→ {1}" -f (Snip $c.Phrase 22), $c.File); $cardPlan++ }
    elseif (-not $tt.Contains($c.Phrase)) { Write-Host ("  找不到卡片文字「{0}」" -f (Snip $c.Phrase 22)) -ForegroundColor Yellow }
  }
  if ($cardPlan -gt 0 -and (Ask "套用 $cardPlan 張卡片的連結修改？")) { Write-Text $rels[$rel] $t; Mark $rel $true; Done }
  elseif ($cardPlan -eq 0) { Write-Host "沒有需要修改的卡片（可能已經改過）" }
}

# ---------- 5. 全站處理 ----------
Write-Host "`n[5] 全站處理（先統計，再問你）" -ForegroundColor Cyan
$opt = @{ Index = $true; Keywords = $true; Seo = $true; Footer = $true }
$cnt = @{ Index = 0; Keywords = 0; Seo = 0; Footer = 0 }
foreach ($r in $rels.Keys) { $null = Invoke-Sitewide $r (Read-Text $rels[$r]) $opt $cnt }
Write-Host ("  /index.html 連結統一成 /：{0} 處" -f $cnt.Index)
Write-Host ("  移除 meta keywords：{0} 頁" -f $cnt.Keywords)
Write-Host ("  刪除給搜尋引擎看的句子：{0} 處" -f $cnt.Seo)
Write-Host ("  頁尾連結改到專頁：{0} 處" -f $cnt.Footer)
$opt2 = @{ Index = $false; Keywords = $false; Seo = $false; Footer = $false }
if ($cnt.Index -gt 0 -and (Ask "統一 /index.html 連結？")) { $opt2.Index = $true }
if ($cnt.Keywords -gt 0 -and (Ask "移除 meta keywords？")) { $opt2.Keywords = $true }
if ($cnt.Seo -gt 0 -and (Ask "刪除給搜尋引擎看的句子？")) { $opt2.Seo = $true }
if ($cnt.Footer -gt 0 -and (Ask "修改頁尾連結？")) { $opt2.Footer = $true }
if ($opt2.Index -or $opt2.Keywords -or $opt2.Seo -or $opt2.Footer) {
  $cnt2 = @{ Index = 0; Keywords = 0; Seo = 0; Footer = 0 }
  $n = 0
  foreach ($r in $rels.Keys) {
    $old = Read-Text $rels[$r]
    $new = Invoke-Sitewide $r $old $opt2 $cnt2
    if ($new -ne $old) {
      Write-Text $rels[$r] $new
      $isContent = ($opt2.Seo -and ($old -ne $new) -and ($SeoSentences | Where-Object { $old.Contains($_) }))
      Mark $r ([bool]$isContent); $n++
    }
  }
  Write-Host "（共 $n 個頁面）"; Done
}

# ---------- 6. sitemap 清理 ----------
Write-Host "`n[6] sitemap.xml：移除仍是 noindex 的頁面" -ForegroundColor Cyan
$smPath = To-Path "sitemap.xml"
if (Test-Path $smPath) {
  $sm = Read-Text $smPath; $bad = @()
  foreach ($m in [regex]::Matches($sm, '(?is)<loc>\s*(.*?)\s*</loc>')) {
    $loc = $m.Groups[1].Value
    $rel = [uri]::UnescapeDataString(($loc -replace '^https?://[^/]+/?', ''))
    if ($rel -eq '' -or $rel.EndsWith('/')) { $rel = $rel + 'index.html' }
    if ($rels.ContainsKey($rel)) {
      $pt = Read-Text $rels[$rel]
      $isNo = $false
      foreach ($tag in [regex]::Matches($pt, '(?is)<meta\b[^>]*>')) {
        if (($tag.Value -match '(?is)\bname\s*=\s*["''](robots|googlebot)["'']') -and ($tag.Value -match '(?i)noindex')) { $isNo = $true }
      }
      if ($isNo) { $bad += $loc }
    }
  }
  if ($bad.Count -eq 0) { Write-Host "sitemap 裡沒有 noindex 頁面，OK" -ForegroundColor Green }
  else {
    $bad | ForEach-Object { Write-Host "  $_" }
    if (Ask "把以上 $($bad.Count) 個網址從 sitemap.xml 移除？（頁面本身維持 noindex）") {
      foreach ($b in $bad) {
        $pat = '(?is)[ \t]*<url>\s*<loc>\s*' + [regex]::Escape($b) + '\s*</loc>.*?</url>[ \t]*\r?\n?'
        $sm = [regex]::Replace($sm, $pat, '')
      }
      Write-Text $smPath $sm; Mark "sitemap.xml" $false; Done
    }
  }
} else { Write-Host "找不到 sitemap.xml" -ForegroundColor Yellow }

# ---------- 7. 首頁地圖 ----------
Write-Host "`n[7] 首頁地圖" -ForegroundColor Cyan
if ([string]::IsNullOrWhiteSpace($MapEmbedSrc)) {
  Write-Host "你還沒填 `$MapEmbedSrc，所以不換地圖。做法：Google 地圖開你的商家 →「分享」→「嵌入地圖」→ 複製 src=`"...`" 裡的網址，貼到腳本上方 `$MapEmbedSrc 再重跑。" -ForegroundColor Yellow
  Write-Host "（若你的商家是不顯示地址的服務型商家，可能沒有嵌入選項，那就維持現狀或告訴我改成連結按鈕。）"
} elseif ($rels.ContainsKey("index.html")) {
  $t = Read-Text $rels["index.html"]
  $pat = '(?is)(<iframe\b[^>]*\bsrc\s*=\s*["''])[^"'']*q=Taiwan[^"'']*(["''])'
  if ([regex]::IsMatch($t, $pat)) {
    if (Ask "把首頁泛用的台灣地圖換成你的商家地圖？") {
      $t = [regex]::Replace($t, $pat, { param($m) $m.Groups[1].Value + $MapEmbedSrc + $m.Groups[2].Value })
      Write-Text $rels["index.html"] $t; Mark "index.html" $true; Done
    }
  } else { Write-Host "找不到原本的台灣地圖 iframe，略過" }
}

# ---------- 8. 只回報、不修改 ----------
Write-Host "`n[8] 只回報、不修改的項目" -ForegroundColor Cyan
$claim = @(); $minp = @()
foreach ($r in $rels.Keys) {
  $t = Read-Text $rels[$r]
  $n = Count-Of $t "全台唯一"
  if ($n -gt 0) { $claim += [pscustomobject]@{ File = $r; Count = $n } }
  foreach ($m in [regex]::Matches($t, '(最低|最少|起訂)[^<。]{0,14}人[^<。]{0,30}')) {
    if ($m.Value -match '[？"]') { continue }
    $minp += [pscustomobject]@{ File = $r; Text = (Snip $m.Value 60) }
  }
}
Write-Host ("「全台唯一」出現在 {0} 個頁面（用語是否有可查證依據，請自行評估）：" -f $claim.Count)
$claim | Sort-Object Count -Descending | Select-Object -First 8 | ForEach-Object { Write-Host ("  {0}（{1} 次）" -f $_.File, $_.Count) }
Write-Host ("提到「最低／最少／起訂 … 人」的位置共 {0} 處，前 12 筆：" -f $minp.Count)
$minp | Select-Object -First 12 | ForEach-Object { Write-Host ("  {0}：{1}" -f $_.File, $_.Text) }

# ---------- 9. 發佈 ----------
Write-Host "`n[9] 發佈" -ForegroundColor Cyan
if ($Changed.Count -eq 0) { Write-Host "這次沒有修改任何檔案，結束。"; exit 0 }
Write-Host ("共修改 {0} 個檔案（其中內容有變動：{1} 個）" -f $Changed.Count, $Content.Count)
if ($DryRun) { Write-Host "【預覽模式】到此為止。" -ForegroundColor Yellow; exit 0 }
if (-not (Ask "commit 並 push 到 GitHub？")) { Write-Host "已取消（檔案已修改但尚未 commit）"; exit 0 }
for ($i = 0; $i -lt $Changed.Count; $i += 50) {
  $end = [Math]::Min($i + 49, $Changed.Count - 1)
  git add -- @($Changed[$i..$end])
}
git commit -m "網站修正：menu-banquet 行動呼籲、人數說法統一、首頁連結與頁尾、index 連結統一、移除 meta keywords"
git push
if ($LASTEXITCODE -ne 0) { Write-Host "git push 失敗，請把上面的錯誤貼給我" -ForegroundColor Red; exit 1 }

$pages = @($Content | Where-Object { $_ -like '*.html' -and $_ -ne '404.html' })
if ($pages.Count -eq 0) { Write-Host "完成。沒有需要送 IndexNow 的頁面。" -ForegroundColor Green; exit 0 }
if (-not (Ask "等網站部署（約 90 秒）後，用 IndexNow 送出 $($pages.Count) 個有內容變動的頁面？")) { exit 0 }
Write-Host "等待部署 90 秒..."; Start-Sleep -Seconds 90
$urls = @($pages | ForEach-Object { $p = $_ -replace '(^|/)index\.html$', '$1'; "https://$Domain/$p" })
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
