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
