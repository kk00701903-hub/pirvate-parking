// 내 차 찾기 PWA 서비스 워커
// 바로가기 화면을 저장해 두어 인터넷이 약할 때도 앱이 바로 열리게 한다.
const CACHE = "find-my-car-v1";
const FILES = [
  "./",
  "./index.html",
  "./offline.html",
  "./manifest.webmanifest",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/icon-maskable-512.png",
  "./icons/apple-touch-icon.png",
  "./icons/favicon.png"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(FILES)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  // 우리 사이트 파일만 다룬다. 원본 주차장 웹 요청은 건드리지 않는다.
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;

  if (req.mode === "navigate") {
    // 화면: 새 버전을 먼저 시도하고, 실패하면 저장본 → 오프라인 안내
    e.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put("./index.html", copy));
          return res;
        })
        .catch(() =>
          caches.match("./index.html").then((r) => r || caches.match("./offline.html"))
        )
    );
    return;
  }

  // 아이콘 등: 저장본 우선
  e.respondWith(caches.match(req).then((r) => r || fetch(req)));
});
