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