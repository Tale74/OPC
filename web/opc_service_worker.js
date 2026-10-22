const CACHE_NAME = 'opc-v15-pwa-shell-official-icon-20261022';

function shellUrls() {
  return [
    new URL('./', self.registration.scope).href,
    new URL('index.html', self.registration.scope).href,
  ];
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(shellUrls()))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('message', (event) => {
  if (event.data?.type !== 'CACHE_LOADED_RESOURCES') return;
  const urls = Array.isArray(event.data.urls) ? event.data.urls : [];
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    await Promise.allSettled(urls.map(async (value) => {
      let url;
      try {
        url = new URL(value, self.registration.scope);
      } catch (_) {
        return;
      }
      if (url.origin !== self.location.origin) return;
      const request = new Request(url.href, { credentials: 'same-origin' });
      try {
        const response = await fetch(request);
        if (response.ok) await cache.put(request, response.clone());
      } catch (_) {
        // A failed individual asset does not invalidate the rest of the cache.
      }
    }));
    event.ports?.[0]?.postMessage({ type: 'CACHE_LOADED_RESOURCES_COMPLETE' });
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    try {
      const response = await fetch(request);
      if (response.ok) await cache.put(request, response.clone());
      return response;
    } catch (error) {
      const cached = await cache.match(request);
      if (cached) return cached;
      if (request.mode === 'navigate') {
        const shell = await cache.match(shellUrls()[1]) || await cache.match(shellUrls()[0]);
        if (shell) return shell;
      }
      throw error;
    }
  })());
});
