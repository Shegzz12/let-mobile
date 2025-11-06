'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "18d0bed11be84722f6d6d737c5b9ba84",
"assets/AssetManifest.bin.json": "138ab1ac4731fc4b89f58f7cba49be9e",
"assets/AssetManifest.json": "14d85046e44706ac63f5093bf3fba2a4",
"assets/assets/animations/order_success.json": "05bda9abb52bc2bdbe5f8af9914a2d9c",
"assets/assets/images/avatar.jpg": "428c8457ed2fc2668da71f754e57e4ca",
"assets/assets/images/avatar_on_laptop.png": "ea06e4123ba8bab906cd5fba0e662124",
"assets/assets/images/elect_store.jpg": "371ba78224f8e17c5b44361c946197cd",
"assets/assets/images/hand_pressing_phone.png": "a815462c87f36a8cf6edfaaf08778eb3",
"assets/assets/images/intro.png": "d9debf4d4ec7c136d0278fd34f4c0e77",
"assets/assets/images/intro1.png": "87a15448e706dec590b1c0b15515184c",
"assets/assets/images/intro2.png": "c95d051d8526813e3ad0fdcf5b16f64c",
"assets/assets/images/kyoto_store.jpg": "c947cac9a469f78ebc06a0c559fbd9cb",
"assets/assets/images/laptop.jpg": "1f4044c6b71492fe22b044fb759e9795",
"assets/assets/images/let_logo.png": "4fe157d875312b2615ef27635b263d98",
"assets/assets/images/let_symbol.png": "f2cae4df87b579da99ba04af4a9a7d22",
"assets/assets/images/man_and_woman_chatting.png": "15c8ee262f7d3ec018922382b780539e",
"assets/assets/images/man_calling_on_laptop.png": "50bb82164802f14f12c183649cc0ee1e",
"assets/assets/images/man_on_laptop.png": "4b7786931522f9ce3648f41d28cd7c9b",
"assets/assets/images/man_with_luggage.png": "51a24167bf07f5e4120f80204fa05393",
"assets/assets/images/mastercard.png": "1c3eb3499ffb3db456ada39b8f67f535",
"assets/assets/images/segun.jpg": "e3a2efb45cea7dd3e919d61af4b7ef03",
"assets/assets/images/shoe.jpg": "bbb40ce560b3b5f62840c70b597982d4",
"assets/assets/images/shoe2.jpg": "c21a0ddaf0dfb23a6233d987e1645dab",
"assets/assets/images/shoes2.jpg": "be185aedf2b72ac788dce7b7d6402645",
"assets/assets/images/woman_looking_at_internet.png": "0d49129a4ef77b2872e4f9400a5fdac1",
"assets/assets/images/woman_on_laptop.png": "80f407afbd8ffe578fcb7f007eb12dc0",
"assets/assets/images/worktable_man.png": "597b41b76c555976c657cf19b9a9bc86",
"assets/assets/images/worktable_woman.png": "dace5daea0204fe6d4fb1b8a30f9d136",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "4ea370c6472baa8672bef5569c372e0c",
"assets/NOTICES": "87f19489461ddda5e316f81fef2b9768",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "31b36233b366a71360943275d9de8a17",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "ea9b53d57be5b9c291f1d9007192f2cb",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "e8e0b2c07cee6016bc59ebbb2415139a",
"/": "e8e0b2c07cee6016bc59ebbb2415139a",
"main.dart.js": "6382f219f827e18a0aa20749106fc2df",
"manifest.json": "9c49fcb651d3993a6178ee67b234bcfc",
"version.json": "c9403ebb52352508bcf2e2232d19b23c"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
