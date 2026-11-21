/* Service worker for the agenda app.
   - The page itself is fetched from the network first (so updates arrive immediately) and kept for offline use.
   - Icons/manifest are served from the cache.
   - The Supabase library from the CDN is cached so the app also starts offline.
   - Calls to Supabase (login, data) are never touched. */
var CACHE = "agenda-shell-v1";
var SHELL = ["./Agenda.html", "./manifest.json", "./icon-192.png", "./icon-512.png", "./icon-maskable-512.png"];

self.addEventListener("install", function (e) {
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(SHELL); }).then(function () { return self.skipWaiting(); }));
});

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.filter(function (k) { return k !== CACHE; }).map(function (k) { return caches.delete(k); }));
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET") return;
  var url = new URL(req.url);

  /* Supabase library from the CDN: cache first, refresh in the background */
  if (url.hostname === "cdn.jsdelivr.net") {
    e.respondWith(
      caches.open(CACHE).then(function (c) {
        return c.match(req).then(function (hit) {
          var net = fetch(req).then(function (res) { c.put(req, res.clone()); return res; }).catch(function () { return hit; });
          return hit || net;
        });
      })
    );
    return;
  }
  if (url.origin !== location.origin) return;           /* everything else on other hosts: not ours */

  var isPage = req.mode === "navigate" || /\.html$/.test(url.pathname) || /\/$/.test(url.pathname);
  if (isPage) {
    /* network first, bypassing the browser cache; fall back to the saved copy when offline */
    e.respondWith(
      fetch(req, { cache: "no-store" }).then(function (res) {
        if (res.ok && /Agenda\.html$/.test(url.pathname)) {
          var copy = res.clone();
          caches.open(CACHE).then(function (c) { c.put("./Agenda.html", copy); });
        }
        return res;
      }).catch(function () {
        return caches.match("./Agenda.html");
      })
    );
    return;
  }
  /* static files (icons, manifest): cache first */
  e.respondWith(caches.match(req).then(function (hit) { return hit || fetch(req); }));
});
