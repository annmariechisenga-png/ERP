/**
 * dashboard-offline.js
 *
 * Extracted offline / caching logic from erp-dashboard.js:
 *   localStorage public-data cache, in-memory JSON response cache,
 *   connectivity monitoring, timeout handling, and cache refresh.
 *
 * Exposes a global `DashboardOffline` object so it can be wired into any HTML page.
 */
const DashboardOffline = (function () {
    "use strict";

    var PUBLIC_REQUEST_CACHE_TTL_MS = 5 * 60 * 1000;
    var PROTECTED_REQUEST_CACHE_TTL_MS = 20 * 1000;
    var REQUEST_TIMEOUT_MS = 8000;
    var PUBLIC_DATA_CACHE_KEY = "erp.publicDataCache.v1";

    var jsonResponseCache = new Map();
    var inflightJsonRequests = new Map();
    var networkCallbacks = [];
    var state = {
        online: true,
        slowNetwork: false
    };

    function getCookie(name) {
        var match = document.cookie.match(new RegExp("(^|; )" + name + "=([^;]*)"));
        return match ? decodeURIComponent(match[2]) : "";
    }

    function cloneJsonValue(value) {
        try {
            return JSON.parse(JSON.stringify(value));
        } catch (e) {
            return value;
        }
    }

    function buildCacheKey(path, authenticated) {
        return (authenticated ? "auth:" : "public:") + path;
    }

    function getCachedResponse(cacheKey, ttlMs) {
        var cached = jsonResponseCache.get(cacheKey);
        if (!cached) {
            return null;
        }
        if ((Date.now() - cached.savedAt) > ttlMs) {
            jsonResponseCache.delete(cacheKey);
            return null;
        }
        return cloneJsonValue(cached.value);
    }

    function setCachedResponse(cacheKey, value) {
        jsonResponseCache.set(cacheKey, {
            value: cloneJsonValue(value),
            savedAt: Date.now()
        });
    }

    function clearResponseCache(match) {
        if (match === null || match === undefined) {
            jsonResponseCache.clear();
            return;
        }
        var re = match instanceof RegExp ? match : new RegExp(String(match));
        Array.from(jsonResponseCache.keys()).forEach(function (key) {
            if (re.test(key)) {
                jsonResponseCache.delete(key);
            }
        });
    }

    function getPublicDataCache() {
        try {
            var raw = localStorage.getItem(PUBLIC_DATA_CACHE_KEY);
            if (!raw) {
                return null;
            }
            var parsed = JSON.parse(raw);
            if (!parsed || !parsed.savedAt) {
                return null;
            }
            return parsed;
        } catch (e) {
            return null;
        }
    }

    function setPublicDataCache(snapshot) {
        try {
            localStorage.setItem(PUBLIC_DATA_CACHE_KEY, JSON.stringify({
                snapshot: cloneJsonValue(snapshot),
                savedAt: Date.now()
            }));
        } catch (e) {
            console.warn("Unable to save public data cache", e);
        }
    }

    function clearPublicDataCache() {
        try {
            localStorage.removeItem(PUBLIC_DATA_CACHE_KEY);
        } catch (e) {
            console.warn("Unable to clear public data cache", e);
        }
    }

    function isOnline() {
        return state.online;
    }

    function onNetworkChange(callback) {
        if (typeof callback === "function") {
            networkCallbacks.push(callback);
        }
    }

    function notifyNetworkChange() {
        networkCallbacks.forEach(function (callback) {
            try {
                callback(state.online);
            } catch (e) {
                console.error("Network callback error:", e);
            }
        });
    }

    function showConnectivityBanner(message, warning) {
        var banner = document.getElementById("connectivityBanner");
        if (!banner) {
            return;
        }
        banner.textContent = message;
        banner.style.display = message ? "block" : "none";
        banner.className = warning ? "warn-banner" : "info-banner";
    }

    function setOnline(isOnline) {
        state.online = isOnline;
        notifyNetworkChange();
    }

    function bindConnectivity() {
        window.addEventListener("offline", function () {
            setOnline(false);
            showConnectivityBanner("Connection lost. The dashboard is using saved data until the network returns.", true);
        });

        window.addEventListener("online", function () {
            setOnline(true);
            showConnectivityBanner("Connection restored. Refresh to load the latest data.", false);
            window.setTimeout(function () {
                showConnectivityBanner("", false);
            }, 5000);
        });

        if (typeof navigator !== "undefined" && navigator.onLine === false) {
            setOnline(false);
            showConnectivityBanner("You appear to be offline. Review saved data and retry submissions once the backend is reachable.", true);
        }
    }

    function bindRefreshButtons(refreshSelectors) {
        refreshSelectors = refreshSelectors || ["[data-action='refresh-cache']"];
        refreshSelectors.forEach(function (selector) {
            var node = document.querySelector(selector);
            if (node) {
                node.addEventListener("click", function () {
                    clearResponseCache();
                    clearPublicDataCache();
                    if (typeof node.dataset.reload === "string" && window[node.dataset.reload]) {
                        window[node.dataset.reload]();
                    } else if (typeof window.fetchDashboardData === "function") {
                        window.fetchDashboardData();
                    }
                });
            }
        });
    }

    async function fetchWithCache(path, options, authenticated) {
        options = options || {};
        var token = options.token || localStorage.getItem("erp.jwt") || localStorage.getItem("erp_token") || "";
        var timeoutMs = options.timeoutMs !== undefined ? options.timeoutMs : REQUEST_TIMEOUT_MS;
        var cacheTtlMs = options.cacheTtlMs !== undefined ? options.cacheTtlMs : (authenticated ? PROTECTED_REQUEST_CACHE_TTL_MS : PUBLIC_REQUEST_CACHE_TTL_MS);
        var bypassCache = options.bypassCache || false;

        var method = String(options.method || "GET").toUpperCase();
        var headers = new Headers(options.headers || {});
        headers.set("Accept", "application/json");
        if (method !== "GET" && method !== "HEAD" && method !== "OPTIONS" && method !== "TRACE") {
            headers.set("Content-Type", "application/json");
        }
        if (authenticated && token) {
            headers.set("Authorization", "Bearer " + token);
        }
        if (method !== "GET" && method !== "HEAD" && method !== "OPTIONS" && method !== "TRACE") {
            var csrfToken = getCookie("XSRF-TOKEN");
            if (csrfToken && !headers.has("X-XSRF-TOKEN")) {
                headers.set("X-XSRF-TOKEN", csrfToken);
            }
        }

        var cacheKey = method === "GET" && !bypassCache ? buildCacheKey(path, authenticated) : null;
        if (cacheKey && cacheTtlMs > 0) {
            var cached = getCachedResponse(cacheKey, cacheTtlMs);
            if (cached) {
                return cached;
            }
            if (inflightJsonRequests.has(cacheKey)) {
                return inflightJsonRequests.get(cacheKey);
            }
        }

        var requestPromise = (async function () {
            var controller = typeof AbortController !== "undefined" ? new AbortController() : null;
            var timeoutHandle = controller && timeoutMs > 0 ? window.setTimeout(function () { controller.abort(); }, timeoutMs) : null;

            try {
                var response = await fetch(path, {
                    method: method,
                    headers: headers,
                    credentials: options.credentials || "same-origin",
                    body: options.body || undefined,
                    signal: controller ? controller.signal : undefined
                });
                if (!response.ok) {
                    var message = response.status + " " + response.statusText;
                    try {
                        var payload = await response.json();
                        message = payload.message || payload.error || message;
                    } catch (err) {}
                    throw new Error(message);
                }
                var payload = await response.json();
                if (cacheKey && cacheTtlMs > 0) {
                    setCachedResponse(cacheKey, payload);
                }
                if (method !== "GET") {
                    clearResponseCache();
                }
                return payload;
            } catch (error) {
                if (error && error.name === "AbortError") {
                    throw new Error("The request took too long. Using cached or reduced data if available.");
                }
                throw error;
            } finally {
                if (timeoutHandle) {
                    window.clearTimeout(timeoutHandle);
                }
                if (cacheKey) {
                    inflightJsonRequests.delete(cacheKey);
                }
            }
        })();

        if (cacheKey && cacheTtlMs > 0) {
            inflightJsonRequests.set(cacheKey, requestPromise);
        }

        return requestPromise;
    }

    function init(options) {
        options = options || {};
        PUBLIC_REQUEST_CACHE_TTL_MS = options.publicCacheTtlMs || PUBLIC_REQUEST_CACHE_TTL_MS;
        PROTECTED_REQUEST_CACHE_TTL_MS = options.protectedCacheTtlMs || PROTECTED_REQUEST_CACHE_TTL_MS;
        REQUEST_TIMEOUT_MS = options.timeoutMs || REQUEST_TIMEOUT_MS;
        PUBLIC_DATA_CACHE_KEY = options.publicDataCacheKey || PUBLIC_DATA_CACHE_KEY;

        bindConnectivity();
        bindRefreshButtons(options.refreshSelectors);
    }

    return {
        init: init,
        fetchWithCache: fetchWithCache,
        isOnline: isOnline,
        onNetworkChange: onNetworkChange,
        getPublicDataCache: getPublicDataCache,
        setPublicDataCache: setPublicDataCache,
        clearPublicDataCache: clearPublicDataCache,
        clearResponseCache: clearResponseCache,
        buildCacheKey: buildCacheKey,
        getCachedResponse: getCachedResponse,
        setCachedResponse: setCachedResponse,
        constants: {
            PUBLIC_REQUEST_CACHE_TTL_MS: PUBLIC_REQUEST_CACHE_TTL_MS,
            PROTECTED_REQUEST_CACHE_TTL_MS: PROTECTED_REQUEST_CACHE_TTL_MS,
            REQUEST_TIMEOUT_MS: REQUEST_TIMEOUT_MS,
            PUBLIC_DATA_CACHE_KEY: PUBLIC_DATA_CACHE_KEY
        },
        state: state
    };
})();
