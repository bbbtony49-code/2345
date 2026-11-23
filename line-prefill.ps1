<#
  line-prefill.ps1  -  手機版「加入 LINE」改成預填詢問訊息
  在 repo 根目錄（看得到 CNAME 的資料夾）執行：
     powershell -ExecutionPolicy Bypass -File .\line-prefill.ps1 -DryRun   (只預覽)
     powershell -ExecutionPolicy Bypass -File .\line-prefill.ps1           (正式執行)

  只更新一個檔案：js/ga4-events.js（全站已經載入它，所以不用改任何網頁）。
  手機：點任何連到 lin.ee/Tns33CH 的按鈕 → 直接開啟與官方帳號 @599cjpvr 的對話，
        輸入框已預填「日期／人數／地點／場合／預算」格式與來源頁面，客人填完按送出即可。
  電腦：維持原本的加好友 QR 頁。原本的 Google Ads 轉換呼叫與 GA4 事件都保留。
  要改訊息格式：直接改下方 JS 裡 lines 那一段。
#>
param([switch]$DryRun, [switch]$Yes)
$utf8 = New-Object System.Text.UTF8Encoding($false)
if (-not (Test-Path "./CNAME")) { Write-Host "請在 repo 根目錄執行（要看得到 CNAME 檔）"; exit 1 }
if (-not (Test-Path "./.git")) { Write-Host "這個資料夾不是 git repo，請到 2345-repo 資料夾執行"; exit 1 }
$Domain = (Get-Content ./CNAME -Raw).Trim()
if ($DryRun) { Write-Host "【預覽模式】不會修改任何檔案" -ForegroundColor Yellow }

$js = @'
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
      click_url: href.slice(0, 120),
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

/* LINE 預填訊息（只在手機上啟用）
   手機點「加入 LINE」時，直接開啟與官方帳號的對話，並預先填好詢問格式與來源頁面。
   電腦版維持原本的加好友 QR 頁。原本的 Google Ads 轉換呼叫會保留。 */
(function () {
  var OA_ID = '@599cjpvr';
  var OLD = 'lin.ee/Tns33CH';

  function isMobile() {
    return /Android|iPhone|iPad|iPod/i.test(navigator.userAgent || '');
  }

  function buildUrl() {
    var title = (document.title || '').split('｜')[0].replace(/\s+/g, ' ').trim().slice(0, 24);
    var lines = [
      '您好，我想詢問到府私廚／外燴服務',
      '來源頁面：' + (title || '官網') + '（' + location.pathname + '）',
      '日期：',
      '時段（午餐／晚餐）：',
      '地點（縣市區）：',
      '人數：',
      '場合：',
      '預算範圍：',
      '飲食限制或其他需求：'
    ];
    return 'https://line.me/R/oaMessage/' + OA_ID + '/?' + encodeURIComponent(lines.join('\n'));
  }

  function init() {
    try {
      if (!isMobile()) { return; }
      var url = buildUrl();
      var links = document.querySelectorAll('a[href*="' + OLD + '"]');
      for (var i = 0; i < links.length; i++) {
        links[i].setAttribute('href', url);
        links[i].onclick = function () {
          return (typeof window.gtag_report_conversion_line === 'function')
            ? window.gtag_report_conversion_line(url)
            : true;
        };
      }
    } catch (e) { /* 失敗就維持原本的連結 */ }
  }

  if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
  else { init(); }
})();
'@
$js = $js.Replace("`r`n", "`n").TrimEnd() + "`n"

Write-Host "`n[0] 同步最新版本" -ForegroundColor Cyan
git pull

$path = Join-Path (Get-Location).Path "js/ga4-events.js"
if (-not (Test-Path $path)) { Write-Host "找不到 js/ga4-events.js，請先完成 GA4 事件追蹤的安裝" -ForegroundColor Red; exit 1 }
$old = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8).Replace("`r`n", "`n")
if ($old -eq $js) { Write-Host "js/ga4-events.js 已經是最新版，不需要更新。"; exit 0 }
$had = $old.Contains("oaMessage")
Write-Host ("目前的檔案{0}預填功能；更新後會加入／覆蓋為新版（約 {1} 行）。" -f $(if ($had) { "已有舊版" } else { "還沒有" }), ($js -split "`n").Count)
if ($DryRun) { Write-Host "【預覽模式】到此為止。" -ForegroundColor Yellow; exit 0 }

if (-not $Yes) { $a = Read-Host "更新 js/ga4-events.js 並 push？(y/n)"; if ($a -notmatch '^[yY]') { Write-Host "已取消"; exit 0 } }
[System.IO.File]::WriteAllText($path, $js, $utf8)
git add -- js/ga4-events.js
git commit -m "LINE：手機版加入 LINE 改為預填詢問訊息（含來源頁面）"
git push
if ($LASTEXITCODE -ne 0) { Write-Host "git push 失敗，請把上面的錯誤貼給我" -ForegroundColor Red; exit 1 }

Write-Host "`n等待網站部署並檢查（每 30 秒一次，最多 10 分鐘）..." -ForegroundColor Cyan
$ok = $false
for ($i = 1; $i -le 20; $i++) {
  $v = Get-Date -Format yyyyMMddHHmmss
  try {
    $r = (Invoke-WebRequest "https://$Domain/js/ga4-events.js?v=$v" -UseBasicParsing).Content
    if ($r.Contains("oaMessage")) { $ok = $true; break }
  } catch {}
  "第 $i 次檢查：還沒部署完成"
  Start-Sleep -Seconds 30
}
if ($ok) { Write-Host "已上線。請用手機測試：打開網站，點任何『加入 LINE』按鈕。" -ForegroundColor Green }
else { Write-Host "等了 10 分鐘仍未更新，請到 https://github.com/bbbtony49-code/2345/actions 看部署狀態" -ForegroundColor Yellow }
