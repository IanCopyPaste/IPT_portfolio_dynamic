(function () {
    "use strict";

    var dash = window.AdminDash;

    // Per-browser conveniences only; nothing here needs to survive a cleared browser. Every read and
    // write is wrapped, because storage can be blocked (private windows, site data turned off) and
    // the dashboard must still work with the defaults when it is.
    var PREFIX = "adm.";
    var DEFAULTS = {
        pageSize: 10,
        relativeDates: true,
        sidebarCollapsed: false
    };

    var read = function (key) {
        try {
            return window.localStorage.getItem(PREFIX + key);
        } catch (e) {
            return null;
        }
    };

    var write = function (key, value) {
        try {
            if (value === null) {
                window.localStorage.removeItem(PREFIX + key);
            } else {
                window.localStorage.setItem(PREFIX + key, value);
            }
        } catch (e) {
            // Not saved; the setting still applies for as long as the page is open.
        }
    };

    // Stored as strings ("1"/"0" for flags, which is what the inline script in <head> reads for the
    // sidebar), converted back to the default's type here.
    var parse = function (key, raw) {
        var fallback = DEFAULTS[key];

        if (raw === null) {
            return fallback;
        }
        if (typeof fallback === "boolean") {
            return raw === "1";
        }
        var number = parseInt(raw, 10);
        return isNaN(number) ? fallback : number;
    };

    var session = {};

    dash.prefs = {
        get: function (key) {
            return session.hasOwnProperty(key) ? session[key] : parse(key, read(key));
        },

        set: function (key, value) {
            session[key] = value;
            write(key, typeof value === "boolean" ? (value ? "1" : "0") : String(value));
            dash.emit("prefs:changed", { key: key, value: value });
        },

        reset: function () {
            Object.keys(DEFAULTS).forEach(function (key) {
                delete session[key];
                write(key, null);
                dash.emit("prefs:changed", { key: key, value: DEFAULTS[key] });
            });
        }
    };
})();
