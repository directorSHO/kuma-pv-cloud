(() => {
  const usagePath = '/codex/settings/usage';
  const cacheKey = 'codexUsage';
  let host;
  let cached;
  let render;
  let lastReading;

  function syncPage() {
    if (!/^\/codex(?:\/|$)/.test(location.pathname)) {
      host?.remove();
      return;
    }

    if (location.pathname.replace(/\/$/, '') === usagePath) {
      host?.remove();
      const { percent, credits } = readUsage(document.body.innerText);
      if (percent === null && credits === null) return;
      if (lastReading?.percent === percent && lastReading?.credits === credits) return;
      lastReading = { percent, credits };
      cached = { percent, credits, updatedAt: Date.now() };
      chrome.storage.local.set({ [cacheKey]: cached });
      return;
    }

    if (!host) {
      host = document.createElement('div');
      const shadow = host.attachShadow({ mode: 'closed' });
      shadow.innerHTML = `
        <style>
          :host { all: initial; position: fixed; bottom: 16px; right: 16px; z-index: 2147483647; }
          a { display: grid; gap: 7px; min-width: 150px; padding: 10px 13px; border-radius: 12px;
              border: 1px solid #526178; background: #152132; color: #fff; text-decoration: none;
              font: 12px/1.4 system-ui, sans-serif; box-shadow: 0 4px 14px #0004; }
          a:focus-visible { outline: 2px solid #64e7bc; outline-offset: 3px; }
          span { display: flex; justify-content: space-between; gap: 12px; }
          small { color: #becce0; font-size: 11px; }
          progress { width: 100%; height: 5px; accent-color: #64e7bc; }
        </style>
        <a target="_blank" rel="noopener">
          <span>クレジット <strong id="credits">—</strong></span>
          <span>5時間枠の残り <strong id="percent">—</strong></span>
          <progress max="100" aria-label="5時間枠の残り" hidden></progress>
          <small></small>
        </a>`;
      shadow.querySelector('a').href = usagePath;
      render = () => {
        shadow.querySelector('#credits').textContent = cached?.credits ?? '—';
        shadow.querySelector('#percent').textContent = cached?.percent == null ? '—' : `${cached.percent}%`;
        const progress = shadow.querySelector('progress');
        progress.hidden = cached?.percent == null;
        progress.value = cached?.percent ?? 0;
        shadow.querySelector('small').textContent = cached
          ? `取得 ${new Date(cached.updatedAt).toLocaleTimeString('ja-JP', { hour: '2-digit', minute: '2-digit' })} · 利用状況 ↗`
          : '利用状況を開く ↗';
      };
    }
    if (!host.isConnected) document.body.append(host);
    render();
  }

  chrome.storage.local.get(cacheKey).then(result => {
    cached = result[cacheKey];
    syncPage();
    setInterval(syncPage, 2000);
  });
  chrome.storage.onChanged.addListener((changes, area) => {
    if (area !== 'local' || !changes[cacheKey]) return;
    cached = changes[cacheKey].newValue;
    render?.();
  });
})();
