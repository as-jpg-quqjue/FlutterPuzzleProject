// Verifica que la versión web siga siendo una PWA:
//  1. index.html enlaza un manifest válido (nombre, start_url, display e íconos 192/512).
//  2. Se registra un service worker que toma el control de la página.
//  3. La app carga de nuevo SIN conexión, solo desde la caché.
//
// Uso: node verify_pwa.mjs <carpeta build/web> <nombre del repositorio>
import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { chromium } from 'playwright';

const [webDir, repo] = process.argv.slice(2);
if (!webDir || !repo) {
  console.error('Uso: node verify_pwa.mjs <build/web> <repositorio>');
  process.exit(2);
}
const prefix = `/${repo}/`;
const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.svg': 'image/svg+xml',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.bin': 'application/octet-stream',
  '.frag': 'application/octet-stream',
};

// Servidor estático que imita GitHub Pages: el sitio vive en /<repositorio>/.
const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, 'http://localhost');
    if (!url.pathname.startsWith(prefix)) {
      res.writeHead(404).end();
      return;
    }
    let file = path.join(webDir, decodeURIComponent(url.pathname.slice(prefix.length)));
    if ((await stat(file).catch(() => null))?.isDirectory()) file = path.join(file, 'index.html');
    const body = await readFile(file);
    res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' });
    res.end(body);
  } catch {
    res.writeHead(404).end();
  }
});
await new Promise((resolve) => server.listen(0, resolve));
const base = `http://localhost:${server.address().port}${prefix}`;

const failures = [];
const check = (ok, message) => {
  console.log(`${ok ? '✔' : '✘'} ${message}`);
  if (!ok) failures.push(message);
};

const browser = await chromium.launch();
const context = await browser.newContext();
const page = await context.newPage();
page.on('pageerror', (error) => console.log(`  error en la página: ${error.message}`));

try {
  await page.goto(base, { waitUntil: 'load' });

  // 1. Manifest
  const manifestHref = await page.getAttribute('link[rel="manifest"]', 'href');
  check(Boolean(manifestHref), 'index.html enlaza un manifest');
  const manifest = await page.evaluate(async (href) => {
    const response = await fetch(href);
    return response.ok ? response.json() : null;
  }, manifestHref);
  check(Boolean(manifest), 'el manifest se descarga y es JSON válido');
  if (manifest) {
    check(Boolean(manifest.name && manifest.short_name), 'el manifest tiene name y short_name');
    check(Boolean(manifest.start_url), 'el manifest tiene start_url');
    check(['standalone', 'fullscreen', 'minimal-ui'].includes(manifest.display), `display es "${manifest.display}"`);
    const sizes = (manifest.icons || []).map((icon) => icon.sizes);
    check(sizes.includes('192x192') && sizes.includes('512x512'), 'hay íconos de 192x192 y 512x512');
  }

  // 2. Service worker
  const scriptURL = await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.ready;
    return registration.active && registration.active.scriptURL;
  });
  check(Boolean(scriptURL), `service worker activo (${scriptURL})`);

  await page.reload({ waitUntil: 'load' });
  const controlled = await page.evaluate(() => Boolean(navigator.serviceWorker.controller));
  check(controlled, 'el service worker controla la página');
  await page.waitForSelector('#loading', { state: 'detached', timeout: 90000 });
  check(true, 'la app arranca con conexión');

  // 3. Sin conexión
  await context.setOffline(true);
  await page.reload({ waitUntil: 'load' });
  await page.waitForSelector('#loading', { state: 'detached', timeout: 90000 });
  const hasView = await page.evaluate(() => Boolean(document.querySelector('flutter-view, flt-glass-pane')));
  check(hasView, 'la app arranca SIN conexión (todo sale de la caché)');
} catch (error) {
  check(false, `la verificación no pudo terminar: ${error.message}`);
} finally {
  await browser.close();
  server.close();
}

if (failures.length) {
  console.error(`\n${failures.length} verificación(es) fallaron.`);
  process.exit(1);
}
console.log('\nLa versión web es una PWA instalable que funciona sin conexión.');
