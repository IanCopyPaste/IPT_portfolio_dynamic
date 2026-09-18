(function () {
    "use strict";

    var dash = window.AdminDash;

    // undefined = the viewer's own locale, so dates read the way they are used to.
    var numberFormat = new Intl.NumberFormat(undefined);
    var dateFormat = new Intl.DateTimeFormat(undefined, { year: "numeric", month: "short", day: "numeric" });
    var dateTimeFormat = new Intl.DateTimeFormat(undefined, {
        year: "numeric", month: "short", day: "numeric", hour: "numeric", minute: "2-digit"
    });
    var timeFormat = new Intl.DateTimeFormat(undefined, { hour: "numeric", minute: "2-digit" });
    var relativeFormat = new Intl.RelativeTimeFormat(undefined, { numeric: "auto" });

    // Largest unit first; the first one the gap fills at least once is the one used.
    var UNITS = [
        { unit: "year", seconds: 31536000 },
        { unit: "month", seconds: 2592000 },
        { unit: "week", seconds: 604800 },
        { unit: "day", seconds: 86400 },
        { unit: "hour", seconds: 3600 },
        { unit: "minute", seconds: 60 }
    ];

    var format = dash.format = {};

    format.number = function (value) {
        return numberFormat.format(value);
    };

    // Whole-number percentage; 0 of 0 is 0%, not NaN.
    format.percent = function (part, whole) {
        return whole > 0 ? Math.round((part / whole) * 100) : 0;
    };

    format.plural = function (count, singular, plural) {
        return format.number(count) + " " + (count === 1 ? singular : (plural || singular + "s"));
    };

    format.date = function (iso) {
        return dateFormat.format(new Date(iso));
    };

    format.dateTime = function (iso) {
        return dateTimeFormat.format(new Date(iso));
    };

    format.time = function (date) {
        return timeFormat.format(date);
    };

    format.relative = function (iso) {
        var seconds = (new Date(iso).getTime() - Date.now()) / 1000;
        var size = Math.abs(seconds);

        for (var i = 0; i < UNITS.length; i++) {
            if (size >= UNITS[i].seconds) {
                return relativeFormat.format(Math.round(seconds / UNITS[i].seconds), UNITS[i].unit);
            }
        }
        return "just now";
    };

    // A date as the viewer prefers it (Settings > Relative dates). `emptyText` covers a null date,
    // such as an account that has never signed in.
    format.when = function (iso, emptyText) {
        if (!iso) {
            return emptyText || "";
        }
        return dash.prefs.get("relativeDates") ? format.relative(iso) : format.date(iso);
    };

    // A name suffix (AccountRules' list: Jr., Sr., II to V) isn't a surname, so it never gives an initial.
    var SUFFIX = /^(jr\.?|sr\.?|ii|iii|iv|v)$/i;

    // "JD" from "Juan Dela Cruz Jr."; falls back to the username, then to "?".
    format.initials = function (name, username) {
        var words = String(name || username || "").trim().split(/\s+/).filter(function (word) {
            return word && !SUFFIX.test(word);
        });

        if (!words.length) {
            return "?";
        }
        var first = words[0].charAt(0);
        return (words.length === 1 ? first : first + words[words.length - 1].charAt(0)).toUpperCase();
    };

    format.displayName = function (user) {
        return user.fullName || user.username || "Unnamed account";
    };
})();
