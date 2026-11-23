<#
  ga4-events-apply.ps1  -  補上 GA4 的「電話點擊」「LINE 點擊」事件
  在 repo 根目錄（看得到 CNAME 的資料夾）執行：
     powershell -ExecutionPolicy Bypass -File .\ga4-events-apply.ps1 -DryRun   (只預覽)
     powershell -ExecutionPolicy Bypass -File .\ga4-events-apply.ps1           (正式執行)

  做的事：
   1. 診斷：列出 Google Ads 轉換程式碼(AW-11459072287)和 GA4(G-2P9MZY1F46)出現在哪些檔案
   2. 建立 js/ga4-events.js（點 tel: 送 phone_click、點 LINE 連結送 line_click 給 GA4）
   3. 在每個有 GA4 追蹤碼的頁面，於 </body> 前加一行 <script src="/js/ga4-events.js" defer></script>
   4. 確認後 commit + push
  原本送給 Google Ads 的程式碼完全不會被修改。
#>
param([switch]$DryRun)
$utf8 = New-Object System.Text.UTF8Encoding($false)
$GA4 = "G-2P9MZY1F46"
$AWID = "AW-11459072287"
$tag = '<script src="/js/ga4-events.js" defer></script>'

if (-not (Test-Path ".\CNAME")) { Write-Host "請在 repo 根目錄執行（要看得到 CNAME 檔）"; exit 1 }
if (-not (Test-Path ".\.git")) { Write-Host "這個資料夾不是 git repo，請到 2345-repo 資料夾執行"; exit 1 }
$Root = (Get-Location).Path.TrimEnd('\')
if ($DryRun) { Write-Host "【預覽模式】不會修改任何檔案" -ForegroundColor Yellow }

function Read-Text([string]$p) { return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }

Write-Host "`n[0] 同步最新版本" -ForegroundColor Cyan
git pull

# ---------- 1. 診斷 ----------
Write-Host "`n[1] 診斷：追蹤碼在哪裡" -ForegroundColor Cyan
$all = Get-ChildItem -Path $Root -Recurse -File -Include *.html,*.js | Where-Object { $_.FullName -notmatch '\\(\.git|node_modules)\\' }
$hasAw  = @(); $hasGa4 = @(); $hasBoth = 0
foreach ($f in $all) {
  $t = Read-Text $f.FullName
  $rel = ($f.FullName.Substring($Root.Length).TrimStart('\') -replace '\\','/')
  $a = $t.Contains($AWID); $g = $t.Contains($GA4)
  if ($a) { $hasAw += $rel }
  if ($g) { $hasGa4 += $rel }
  if ($a -and $g) { $hasBoth++ }
}
Write-Host ("含 Google Ads ($AWID) 的檔案：{0} 個" -f $hasAw.Count)
Write-Host ("含 GA4 ($GA4) 的檔案：{0} 個" -f $hasGa4.Count)
$jsAw = @($hasAw | Where-Object { $_ -like '*.js' })
if ($jsAw.Count -gt 0) { Write-Host "Ads 轉換程式碼放在這些 JS 檔：$($jsAw -join ', ')" }
$sample = @($hasAw | Where-Object { $_ -like '*.html' } | Select-Object -First 3)
if ($sample.Count -gt 0) { Write-Host "Ads 程式碼出現的頁面範例：$($sample -join ', ')" }

# ---------- 2. 建立 JS 檔 ----------
Write-Host "`n[2] 建立 js/ga4-events.js" -ForegroundColor Cyan
$jsPath = Join-Path $Root "js\ga4-events.js"
$jsContent = @'
/* GA4 事件追蹤：電話與 LINE 點擊
   只負責把點擊送給 GA4，不影響原本送給 Google Ads 的轉換程式碼。 */
(function () {
  var GA4_ID = 'G-2P9MZY1F46';

  function send(name, params) {
    try {
      if (typeof window.gtag !== 'function') { return; }
      params = params || {};
      params.send_to = GA4_ID;
      params.transport_type = 'beacon';
      window.gtag('event', name, params);
    } catch (e) { /* 追蹤失敗不能影響網站使用 */ }
  }

  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t || !t.closest) { return; }
    var a = t.closest('a[href]');
    if (!a) { return; }

    var href = (a.getAttribute('href') || '').trim();
    var lower = href.toLowerCase();
    var info = {
      click_url: href.slice(0, 200),
      click_text: (a.textContent || '').replace(/\s+/g, ' ').trim().slice(0, 60),
      page_path: location.pathname
    };

    if (lower.indexOf('tel:') === 0) {
      send('phone_click', info);
      return;
    }

    var host = '';
    try { host = new URL(href, location.href).hostname.toLowerCase(); } catch (e) {}
    if (lower.indexOf('line://') === 0 ||
        host === 'line.me' || host === 'lin.ee' ||
        (host.length > 8 && host.slice(-8) === '.line.me')) {
      send('line_click', info);
    }
  }, true);
})();
'@
$jsContent = $jsContent.Replace("`r`n", "`n")
$Changed = New-Object System.Collections.Generic.List[string]
$needJs = $true
if (Test-Path $jsPath) { if ((Read-Text $jsPath).Replace("`r`n","`n").TrimEnd() -eq $jsContent.TrimEnd()) { $needJs = $false } }
if ($needJs) {
  if (-not $DryRun) {
    if (-not (Test-Path (Join-Path $Root "js"))) { New-Item -ItemType Directory -Path (Join-Path $Root "js") | Out-Null }
    [System.IO.File]::WriteAllText($jsPath, $jsContent, $utf8)
  }
  [void]$Changed.Add("js/ga4-events.js"); Write-Host "已建立／更新 js/ga4-events.js"
} else { Write-Host "js/ga4-events.js 已是最新" }

# ---------- 3. 在頁面加入 script ----------
Write-Host "`n[3] 在有 GA4 追蹤碼的頁面加入 script" -ForegroundColor Cyan
$rx = New-Object System.Text.RegularExpressions.Regex('</body>', ([System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::RightToLeft))
$added = 0; $already = 0; $noGa4 = @(); $noBody = @()
$pages = Get-ChildItem -Path $Root -Recurse -File -Filter *.html | Where-Object { $_.FullName -notmatch '\\(\.git|node_modules)\\' }
foreach ($f in $pages) {
  $rel = ($f.FullName.Substring($Root.Length).TrimStart('\') -replace '\\','/')
  $t = Read-Text $f.FullName
  if ($t.Contains('ga4-events.js')) { $already++; continue }
  if (-not $t.Contains($GA4)) { $noGa4 += $rel; continue }
  $m = $rx.Match($t)
  if (-not $m.Success) { $noBody += $rel; continue }
  $nl = "`n"; if ($t.Contains("`r`n")) { $nl = "`r`n" }
  $t2 = $t.Insert($m.Index, $tag + $nl)
  if (-not $DryRun) { [System.IO.File]::WriteAllText($f.FullName, $t2, $utf8) }
  [void]$Changed.Add($rel); $added++
}
Write-Host "已加入：$added 頁；原本就有：$already 頁"
if ($noGa4.Count -gt 0) {
  Write-Host ("沒有 GA4 追蹤碼、未處理的頁面：{0} 頁（前 10 個）" -f $noGa4.Count) -ForegroundColor Yellow
  $noGa4 | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
}
if ($noBody.Count -gt 0) { Write-Host "找不到 </body>、未處理：$($noBody -join ', ')" -ForegroundColor Yellow }

# ---------- 4. 發佈 ----------
Write-Host "`n[4] 發佈" -ForegroundColor Cyan
if ($Changed.Count -eq 0) { Write-Host "沒有需要修改的檔案，結束。"; exit 0 }
if ($DryRun) { Write-Host "【預覽模式】共有 $($Changed.Count) 個檔案會被修改，到此為止。" -ForegroundColor Yellow; exit 0 }
$a = Read-Host "共 $($Changed.Count) 個檔案要 commit 並 push？(y/n)"
if ($a -notmatch '^[yY]') { Write-Host "已取消（檔案已修改但尚未 commit）"; exit 0 }
for ($i = 0; $i -lt $Changed.Count; $i += 50) {
  $end = [Math]::Min($i + 49, $Changed.Count - 1)
  git add -- @($Changed[$i..$end])
}
git commit -m "GA4：補上電話點擊(phone_click)與 LINE 點擊(line_click)事件"
git push
if ($LASTEXITCODE -ne 0) { Write-Host "git push 失敗，請把上面的錯誤貼給我" -ForegroundColor Red; exit 1 }
Write-Host "`n完成。等 1 至 2 分鐘部署後，照說明到 GA4 即時報表測試。" -ForegroundColor Green
