// Shared RPC module for on-chain gallery loaders
(function () {
    "use strict";

    var CONTRACT = "0x1745FEd944c387C9Bfe3a487598F36f98721331a";

    var RPC_URLS = [
        "https://rpc.mevblocker.io",
        "https://ethereum.public.blockpi.network/v1/rpc/public",
        "https://eth.drpc.org",
        "https://0xrpc.io/eth",
        "https://rpc.flashbots.net",
        "https://rpc.fullsend.to",
    ];

    var MAX_RETRIES = 3;

    var SEL_INDEX = "0x2986c0e5";
    var SEL_ESSAY = "0x427158f6";
    var SEL_SCULPTURE_MEDIA = "0x527d0da2";
    var SEL_TOKEN_URI = "0x1675f455";

    // --- ABI helpers ---

    function encodeUint256(n) {
        return n.toString(16).padStart(64, "0");
    }

    function hexToBytes(hex) {
        if (hex.startsWith("0x")) hex = hex.slice(2);
        var bytes = new Uint8Array(hex.length / 2);
        for (var i = 0; i < hex.length; i += 2) {
            bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }
        return bytes;
    }

    function decodeString(hex) {
        if (hex.startsWith("0x")) hex = hex.slice(2);
        if (hex.length < 128) return "";
        var offset = parseInt(hex.substr(0, 64), 16) * 2;
        var len = parseInt(hex.substr(offset, 64), 16);
        var dataStart = offset + 64;
        var dataHex = hex.substr(dataStart, len * 2);
        var bytes = hexToBytes(dataHex);
        return new TextDecoder("utf-8").decode(bytes);
    }

    // --- localStorage cache (10s TTL) ---

    function getCached(key) {
        try {
            var item = JSON.parse(localStorage.getItem("rpc_" + key));
            if (item && Date.now() - item.t < 10000) return item.v;
            localStorage.removeItem("rpc_" + key);
        } catch (e) {}
        return null;
    }

    function setCache(key, value) {
        try {
            localStorage.setItem("rpc_" + key, JSON.stringify({ v: value, t: Date.now() }));
        } catch (e) {}
    }

    // --- RPC caller with fallback + retry ---

    function wait(ms) {
        return new Promise(function (resolve) {
            setTimeout(resolve, ms);
        });
    }

    function tryRpc(data, rpcIndex) {
        if (rpcIndex >= RPC_URLS.length) {
            return Promise.reject(new Error("cycle"));
        }
        var controller = new AbortController();
        var timeout = setTimeout(function () {
            controller.abort();
        }, 30000);
        return fetch(RPC_URLS[rpcIndex], {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                jsonrpc: "2.0",
                id: 1,
                method: "eth_call",
                params: [{ to: CONTRACT, data: data }, "latest"],
            }),
            signal: controller.signal,
        })
            .then(function (res) {
                clearTimeout(timeout);
                return res.json();
            })
            .then(function (json) {
                if (json.error || !json.result || json.result === "0x") {
                    throw new Error(json.error ? json.error.message : "empty result");
                }
                return json.result;
            })
            .catch(function () {
                clearTimeout(timeout);
                return tryRpc(data, rpcIndex + 1);
            });
    }

    function ethCall(data, attempt) {
        if (attempt === undefined) attempt = 0;
        // Check cache first
        var cached = getCached(data);
        if (cached) return Promise.resolve(cached);
        if (attempt >= MAX_RETRIES) {
            return Promise.reject(new Error("All RPCs failed after " + MAX_RETRIES + " retries"));
        }
        return tryRpc(data, 0)
            .then(function (result) {
                setCache(data, result);
                return result;
            })
            .catch(function () {
                return wait(2000 * (attempt + 1)).then(function () {
                    return ethCall(data, attempt + 1);
                });
            });
    }

    // --- Public API ---

    window.callIndex = function () {
        return ethCall(SEL_INDEX).then(decodeString);
    };

    window.callEssay = function () {
        return ethCall(SEL_ESSAY).then(decodeString);
    };

    window.callSculptureMedia = function (i) {
        return ethCall(SEL_SCULPTURE_MEDIA + encodeUint256(i)).then(decodeString);
    };

    window.callTokenUri = function (i) {
        return ethCall(SEL_TOKEN_URI + encodeUint256(i)).then(decodeString);
    };
})();
