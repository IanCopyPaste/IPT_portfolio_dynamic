(function () {
    "use strict";

    var dash = window.AdminDash;

    var BASE = "/AdminApi/";
    var SIGN_IN_URL = "/Admin.aspx";
    var tokenMeta = document.querySelector('meta[name="csrf-token"]');
    var csrfToken = tokenMeta ? tokenMeta.getAttribute("content") : "";

    // Rejections carry the server's message (safe to show), the HTTP status, and for a form the
    // per-field messages. A 401 means the session ended: the admin is sent to sign in again and the
    // promise is left pending, so no caller flashes an error on the way out.
    var request = function (path, options) {
        options.credentials = "same-origin";
        options.headers = options.headers || {};
        options.headers.Accept = "application/json";

        return fetch(BASE + path, options).then(function (response) {
            if (response.status === 401) {
                window.location.href = SIGN_IN_URL;
                return new Promise(function () { });
            }

            return response.json().catch(function () {
                return {};
            }).then(function (body) {
                if (!response.ok) {
                    var error = new Error(body.error || "The server answered " + response.status + ". Try again.");
                    error.status = response.status;
                    error.fields = body.fields || null;
                    throw error;
                }
                return body;
            });
        }, function (failure) {
            // A deliberately cancelled request is passed on untouched, so callers can ignore it.
            if (failure && failure.name === "AbortError") {
                throw failure;
            }
            throw new Error("Couldn't reach the server. Check your connection and try again.");
        });
    };

    dash.isAbort = function (error) {
        return !!error && error.name === "AbortError";
    };

    dash.api = {
        get: function (path, params, signal) {
            var query = Object.keys(params || {}).filter(function (key) {
                return params[key] !== "" && params[key] !== null && params[key] !== undefined;
            }).map(function (key) {
                return encodeURIComponent(key) + "=" + encodeURIComponent(params[key]);
            }).join("&");

            return request(path + (query ? "?" + query : ""), { method: "GET", signal: signal });
        },

        post: function (path, body) {
            return request(path, {
                method: "POST",
                headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
                body: JSON.stringify(body || {})
            });
        }
    };
})();
