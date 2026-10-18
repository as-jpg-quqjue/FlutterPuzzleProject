// Service worker del 15-Puzzle: permite instalar la app y jugar sin conexión.
//
// En el despliegue (GitHub Actions) se agregan al inicio de este archivo
// `self.__PRECACHE` (todos los archivos de la versión web) y
// `self.__VERSION` (el commit), así la primera visita deja todo guardado
// y cada versión nueva reemplaza la caché anterior.
const PRECACHE = self.__PRECACHE || [];
const CACHE = 'puzzle-' + (self.__VERSION || 'dev');
const FONT_HOSTS = ['fonts.gstatic.com', 'fonts.googleapis.com'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) =>
        cache.addAll(PRECACHE.map((url) => new Request(url, { cache: 'reload' }))),
      )
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key.startsWith('puzzle-') && key !== CACHE)
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

// Primero la red (para recibir versiones nuevas); si no hay conexión, la caché.
async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  try {
    const response = await fetch(request);
    if (response && response.ok) cache.put(request, response.clone());
    return response;
  } catch (error) {
    const cached =
      (await cache.match(request, { ignoreSearch: true })) ||
      (request.mode === 'navigate' ? await cache.match('index.html') : undefined);
    if (cached) return cached;
    throw error;
  }
}

// Primero la caché (archivos que no cambian dentro de una versión).
async function cacheFirst(request) {
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request, { ignoreSearch: true });
  if (cached) return cached;
  const response = await fetch(request);
  if (response && (response.ok || response.type === 'opaque')) {
    cache.put(request, response.clone());
  }
  return response;
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);

  if (url.origin !== self.location.origin) {
    // Fuentes de Google que Flutter descarga para el texto.
    if (FONT_HOSTS.includes(url.hostname)) event.respondWith(cacheFirst(request));
    return;
  }

  const isEntryPoint =
    request.mode === 'navigate' ||
    url.pathname.endsWith('/') ||
    url.pathname.endsWith('index.html') ||
    url.pathname.endsWith('flutter_bootstrap.js') ||
    url.pathname.endsWith('version.json') ||
    url.pathname.endsWith('manifest.json');

  event.respondWith(isEntryPoint ? networkFirst(request) : cacheFirst(request));
});
